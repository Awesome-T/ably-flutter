import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';

import '../../../ably_flutter.dart';
import '../message.dart';
import '../platform_object.dart';
import 'presence.dart';
import 'rest.dart';

/// Plugin based implementation of Rest channel
class RestChannel extends PlatformObject implements RestChannelInterface {
  @override
  RestInterface rest;

  @override
  String name;

  @override
  ChannelOptions options;

  RestPresence _presence;

  /// instantiates with [Rest], [name] and [ChannelOptions]
  RestChannel(this.rest, this.name, this.options) {
    _presence = RestPresence(this);
  }

  @override
  RestPresence get presence => _presence;

  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async => (rest as Rest).handle;

  @override
  Future<PaginatedResult<Message>> history([
    RestHistoryParams params,
  ]) async {
    final message = await invoke<AblyMessage>(PlatformMethod.restHistory, {
      TxTransportKeys.channelName: name,
      if (params != null) TxTransportKeys.params: params
    });
    return PaginatedResult<Message>.fromAblyMessage(message);
  }

  final _publishQueue = Queue<_PublishQueueItem>();
  Completer<void> _authCallbackCompleter;

  @override
  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    Object data,
  }) async {
    var _messages = messages;
    if (_messages == null) {
      if (message != null) {
        _messages = [message];
      } else {
        _messages = [Message(name: name, data: data)];
      }
    }
    final queueItem = _PublishQueueItem(Completer<void>(), _messages);
    _publishQueue.add(queueItem);
    unawaited(_publishInternal());
    return queueItem.completer.future;
  }

  bool _publishInternalRunning = false;

  Future<void> _publishInternal() async {
    if (_publishInternalRunning) {
      return;
    }
    _publishInternalRunning = true;

    while (_publishQueue.isNotEmpty) {
      final item = _publishQueue.first;
      // This is the only place where failed items are removed from the queue.
      // In all other places (timeout exceptions) only the Completer is
      // completed with an error but left in the queue.  Other attempts became a
      // bit unwieldy.
      if (item.completer.isCompleted) {
        _publishQueue.remove(item);
        continue;
      }

      try {
        final _map = <String, Object>{
          'channel': name,
          'messages': item.messages
        };

        await invoke(PlatformMethod.publish, _map);

        _publishQueue.remove(item);

        // The Completer could have timed out in the meantime and completing a
        // completed Completer would cause an exception, so we check first.
        if (!item.completer.isCompleted) {
          item.completer.complete();
        }
      } on PlatformException catch (pe) {
        if (pe.code == ErrorCodes.authCallbackFailure.toString()) {
          if (_authCallbackCompleter != null) {
            return;
          }
          _authCallbackCompleter = Completer<void>();
          try {
            await _authCallbackCompleter.future.timeout(
              Timeouts.retryOperationOnAuthFailure,
              onTimeout: () => _publishQueue
                  .where((e) => !e.completer.isCompleted)
                  .forEach((e) => e.completer.completeError(
                        TimeoutException(
                          'Timed out',
                          Timeouts.retryOperationOnAuthFailure,
                        ),
                      )),
            );
          } finally {
            _authCallbackCompleter = null;
          }
        } else {
          _publishQueue
              .where((e) => !e.completer.isCompleted)
              .forEach((e) => e.completer.completeError(AblyException(
                    pe.code,
                    pe.message,
                    pe.details as ErrorInfo,
                  )));
        }
      } on Exception {
        // removing item from queue and rethrowing exception
        _publishQueue.remove(item);
        rethrow;
      }
    }
    _publishInternalRunning = false;
  }

  /// @internal
  /// required due to the complications involved in the way ably-java expects
  /// authCallback to be performed synchronously, while method channel call from
  /// platform side to dart side is asynchronous
  ///
  /// discussion: https://github.com/ably/ably-flutter/issues/31
  void authUpdateComplete() {
    _authCallbackCompleter?.complete();
  }

  @override
  Future<void> setOptions(ChannelOptions options) async {
    throw UnimplementedError();
  }
}

/// A collection of rest channel objects
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSN1
class RestPlatformChannels extends RestChannels<RestChannel> {
  /// instantiates with the ably [Rest] instance
  RestPlatformChannels(Rest rest) : super(rest);

  @override
  RestChannel createChannel(String name, ChannelOptions options) =>
      RestChannel(rest, name, options);
}

/// An item for used to enqueue a message to be published after an ongoing
/// authCallback is completed
class _PublishQueueItem {
  final List<Message> messages;
  final Completer<void> completer;

  _PublishQueueItem(this.completer, this.messages);
}
