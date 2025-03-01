import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:crypto/crypto.dart';
import 'package:rxdart/rxdart.dart';

import 'constants.dart';

class EncryptedMessagingService {
  final ably.Realtime _realtime;
  final ably.Rest _rest;
  late final ably.RealtimeChannel? _realtimeChannel;
  late final ably.RestChannel? _restChannel;

  final BehaviorSubject<List<ably.Message>> messageHistoryBehaviorSubject =
      BehaviorSubject<List<ably.Message>>.seeded([]);

  ValueStream<List<ably.Message>> get messageHistoryStream =>
      messageHistoryBehaviorSubject.stream;

  static const examplePassword = 'password-to-encrypt-and-decrypt-text';

  // This is a quick way to create a key from a password. In production,
  // you should either create a random key or use a key derivation
  // function (KDF) or other secure, attack-resistance mechanism instead.
  // However, in the example app, we use this so that 2 devices running
  // the example app can decrypt each other's message.
  Uint8List get keyFromPassword {
    final data = utf8.encode(examplePassword);
    final digest = sha256.convert(data);
    print('Length of digest: ${digest.bytes.length}');
    return Uint8List.fromList(digest.bytes);
  }

  EncryptedMessagingService(this._realtime, this._rest) {
    _restChannel = _rest.channels.get(Constants.encryptedChannelName);
    _realtimeChannel = _realtime.channels.get(Constants.encryptedChannelName);
  }

  void clearMessageHistory() {
    messageHistoryBehaviorSubject.add([]);
  }

  Future<void> initialize() async {
    final cipherParams =
        await ably.Crypto.getDefaultParams(key: keyFromPassword);
    final restChannelOptions =
        ably.RestChannelOptions(cipherParams: cipherParams);
    await _restChannel!.setOptions(restChannelOptions);

    final channelOptions =
        ably.RealtimeChannelOptions(cipherParams: cipherParams);
    await _realtimeChannel!.setOptions(channelOptions);
  }

  Future<void> connectRealtime() async {
    if (_realtime.connection.state != ably.ConnectionState.connected) {
      await _realtime.connect();
    }
  }

  StreamSubscription<ably.Message>? _channelSubscription;
  StreamSubscription<ably.ChannelStateChange>? channelStateChangeSubscription;

  Future<void> logChannelMessages() async {
    await connectRealtime();
    channelStateChangeSubscription = _realtimeChannel!.on().listen((event) {
      print('on().listen ChannelState: ${event.current}');
      print('on().listen reason: ${event.reason}');
    });
    await _realtimeChannel!.attach();
    _channelSubscription ??= _realtimeChannel!.subscribe().listen((event) {
      final newList = List<ably.Message>.from(messageHistoryStream.value)
        ..add(event);
      messageHistoryBehaviorSubject.add(newList);
      print('subscribe().listen name: ${event.name}');
      print('subscribe().listen data: ${event.data}');
    });
  }

  Future<void> publishRealtimeMessage(
      String name, Map<String, dynamic> data) async {
    await _realtimeChannel?.publish(
        message: ably.Message(name: name, data: data));
  }

  Future<void> publishRestMessage(
      String name, Map<String, dynamic> data) async {
    await _restChannel?.publish(message: ably.Message(name: name, data: data));
  }

  Future<void> unsubscribeAndDetach() async {
    await _channelSubscription?.cancel();
    await channelStateChangeSubscription?.cancel();
    _channelSubscription = null;
    channelStateChangeSubscription = null;
    await _realtimeChannel?.detach();
  }
}
