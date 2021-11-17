import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../../error/error.dart';
import '../platform.dart';
import 'ably_event_message.dart';

/// An object which has a live counterpart in the Platform client library SDK,
/// where that live counterpart is held as a strong reference by the plugin
/// implementation.
abstract class PlatformObject {
  Future<int>? _handle;
  int? _handleValue; // Only for logging. Otherwise use _handle instead.

  /// immediately instantiates an object on platform side by calling
  /// [createPlatformInstance] if [fetchHandle] is true,
  /// otherwise, platform instance will be created only when
  /// [createPlatformInstance] is explicitly called.
  PlatformObject({bool fetchHandle = true}) {
    if (fetchHandle) {
      _handle = _acquireHandle();
    }
  }

  @override
  String toString() => 'Ably Platform Object $_handleValue';

  /// creates an instance of this object on platform side
  Future<int?> createPlatformInstance();

  /// returns [_handle] which will be same as handle on platform side
  ///
  /// if [_handle] is empty, it creates platform instance, acquires handle,
  /// updates [_handle] and returns it.
  Future<int> get handle async => _handle ??= _acquireHandle();

  Future<int> _acquireHandle() =>
      createPlatformInstance().then((value) => (_handleValue = value)!);

  /// [MethodChannel] to make method calls to platform side
  MethodChannel get methodChannel => Platform.methodChannel;

  /// [EventChannel] to register events on platform side
  StreamsChannel get eventChannel => Platform.streamsChannel;

  /// invoke platform method channel without AblyMessage encapsulation
  @protected
  Future<T?> invokeRaw<T>(
    final String method, [
    final Object? arguments,
  ]) async =>
      Platform.invokePlatformMethod<T>(method, arguments);

  /// invoke platform method channel with AblyMessage encapsulation
  ///
  /// this is similar to [invoke], but ensures the response is not null
  Future<T> invokeRequest<T>(final String method,
      [final Object? argument]) async {
    final response = await invoke<T>(method, argument);
    if (response == null) {
      throw AblyException(
        'Platform communication error. Response cannot be null for $method',
      );
    } else {
      return response;
    }
  }

  /// invoke platform method channel with AblyMessage encapsulation
  Future<T?> invoke<T>(final String method, [final Object? argument]) async {
    final _handle = await handle;
    final message = (null != argument)
        ? AblyMessage(AblyMessage(argument, handle: _handle))
        : AblyMessage(_handle);
    return invokeRaw<T>(method, message);
  }

  Future<Stream<T>> _listen<T>(
    final String eventName, [
    final Object? payload,
  ]) async =>
      eventChannel.receiveBroadcastStream<T>(
        AblyMessage(
          AblyEventMessage(eventName, payload),
          handle: await handle,
        ),
      );

  /// Listen for events
  @protected
  Stream<T> listen<T>(final String method, [final Object? payload]) {
    // ignore: close_sinks, will be closed by listener
    final controller = StreamController<T>();
    _listen<T>(method, payload).then(controller.addStream);
    return controller.stream;
  }
}
