import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

import '../../../../ably_flutter.dart';
import '../../../common/src/backwards_compatibility.dart';
import '../../../error/error.dart';
import '../../../generated/platform_constants.dart';
import '../../../message/message.dart';
import '../../../rest/rest.dart';
import '../../platform.dart';
import '../publish_queue_item.dart';

/// Plugin based implementation of Rest channel
class RestChannel extends PlatformObject implements RestChannelInterface {
  @override
  RestInterface rest;

  @override
  PushChannel push;

  @override
  String name;

  late RestPresence _presence;

  /// instantiates with [Rest], [name] and [RestChannelOptions]
  RestChannel(this.rest, this.push, this.name) {
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
    RestHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage>(
      PlatformMethod.restHistory,
      {
        TxTransportKeys.channelName: name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<Message>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult>(message),
    );
  }

  final _publishQueue = Queue<PublishQueueItem>();
  Completer<void>? _authCallbackCompleter;

  @override
  Future<void> publish({
    Message? message,
    List<Message>? messages,
    String? name,
    Object? data,
  }) async {
    messages ??= [
      if (message == null) Message(name: name, data: data) else message
    ];
    final queueItem = PublishQueueItem(Completer<void>(), messages);
    _publishQueue.add(queueItem);
    unawaitedWorkaroundForDartPre214(_publishInternal());
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
          TxTransportKeys.channelName: name,
          TxTransportKeys.messages: item.messages,
        };

        await invoke(PlatformMethod.publish, _map);

        _publishQueue.remove(item);

        // The Completer could have timed out in the meantime and completing a
        // completed Completer would cause an exception, so we check first.
        if (!item.completer.isCompleted) {
          item.completer.complete();
        }
      } on AblyException catch (ae) {
        if (ae.code == ErrorCodes.authCallbackFailure.toString()) {
          if (_authCallbackCompleter != null) {
            return;
          }
          _authCallbackCompleter = Completer<void>();
          try {
            await _authCallbackCompleter!.future.timeout(
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
              .forEach((e) => e.completer.completeError(ae));
        }
      } on PlatformException catch (pe) {
        _publishQueue.where((e) => !e.completer.isCompleted).forEach((e) =>
            e.completer.completeError(AblyException.fromPlatformException(pe)));
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
  Future<void> setOptions(RestChannelOptions options) =>
      invoke(PlatformMethod.setRestChannelOptions, {
        TxTransportKeys.channelName: name,
        TxTransportKeys.options: options,
      });
}
