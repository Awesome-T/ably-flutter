import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/impl/message.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';

import '../utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MockMethodCallManager manager;

  setUp(() {
    manager = MockMethodCallManager();
    manager.methodChannel.setMockMethodCallHandler(manager.handler);
  });

  tearDown(() {
    manager.methodChannel.setMockMethodCallHandler(null);
  });

  group('realtime#channels#channel', () {
    test('publish realtime message without authCallback', () async {
      // setup
      final realtime = Realtime(key: 'TEST-KEY');
      final channel = realtime.channels.get('test');

      // exercise
      await channel.publish(name: 'name', data: 'data1');
      await channel.publish(message: Message(name: 'name', data: 'data'));
      await channel.publish(messages: [Message(name: 'name', data: 'data')]);

      // verification
      expect(manager.publishedMessages.length, 3);
      final firstMessage =
          manager.publishedMessages.first.message as AblyMessage;
      final messageData = firstMessage.message as Map<dynamic, dynamic>;
      expect(messageData['channel'], 'test');
      expect(messageData['messages'], isA<List>());
      final messages = List<Message>.from(messageData['messages'] as List);
      expect(messages[0].name, 'name');
      expect(messages[0].data, 'data1');
    });

    test('publish message with authCallback', () async {
      // setup
      final authCallback = expectAsync1((token) async {}, max: 2);

      final options = ClientOptions()
        ..authCallback = authCallback
        ..authUrl = 'hasAuthCallback';
      final realtime = Realtime(options: options, key: 'TEST-KEY');

      final channel = realtime.channels.get('test');

      // exercise
      await channel.publish(name: 'name', data: 'data2');

      // verification

      expect(manager.publishedMessages.length, 1);
      final firstMessage =
          manager.publishedMessages.first.message as AblyMessage;
      final messageData = firstMessage.message as Map<dynamic, dynamic>;
      expect(messageData['channel'], 'test');
      expect(messageData['messages'], isA<List>());
      final messages = List<Message>.from(messageData['messages'] as List);
      expect(messages[0].name, 'name');
      expect(messages[0].data, 'data2');
    });

    test('publish realtime message with authCallback timing out', () async {
      // setup
      final tooMuchDelay =
          Timeouts.retryOperationOnAuthFailure + const Duration(seconds: 2);
      var authCallbackCounter = 0;

      Future timingOutOnceThenSucceedsAuthCallback(TokenParams token) {
        if (authCallbackCounter == 0) {
          authCallbackCounter++;
          throw TimeoutException('Timed out');
        }
        return Future.value();
      }

      unawaited(
        fakeAsync((async) async {
          final options = ClientOptions()
            ..authCallback = timingOutOnceThenSucceedsAuthCallback
            ..authUrl = 'hasAuthCallback';
          final realtime = Realtime(options: options, key: 'TEST-KEY');
          final channel = realtime.channels.get('test');

          // exercise
          final future1 = channel.publish(name: 'name', data: 'data3-1');
          final future2 = channel.publish(name: 'name', data: 'data3-2');

          // verification
          expect(future1, throwsA(isA<AblyException>()));
          expect(future2, throwsA(isA<AblyException>()));

          async.elapse(tooMuchDelay);

          expect(manager.publishedMessages.length, 0);

          // Send another message after timeout with authCallback succeeding

          // setup
          // exercise
          final future3 = channel.publish(name: 'name', data: 'data3-3');

          // verification
          async.elapse(Duration.zero);
          await future3;

          expect(manager.publishedMessages.length, 1);

          final firstMessage =
              manager.publishedMessages.first.message as AblyMessage;
          final messageData = firstMessage.message as Map<dynamic, dynamic>;
          expect(messageData['channel'], 'test');
          expect(messageData['messages'], isA<List>());
          final messages = List<Message>.from(messageData['messages'] as List);
          expect(messages[0].name, 'name');
          expect(messages[0].data, 'data3-2');
        }),
      );
    });

    test('publish 2 realtime messages with authCallback', () async {
      // setup
      final authCallback = expectAsync1((token) async {});

      final options = ClientOptions()
        ..authCallback = authCallback
        ..authUrl = 'hasAuthCallback';
      final realtime = Realtime(options: options, key: 'TEST-KEY');
      final channel = realtime.channels.get('test');

      // exercise
      await channel.publish(name: 'name', data: 'data4');
      await channel.publish(name: 'name', data: 'data5');

      // verification
      expect(manager.publishedMessages.length, 2);
      final message0 = manager.publishedMessages[0].message as AblyMessage;
      final messageData0 = message0.message as Map<dynamic, dynamic>;
      expect(messageData0['channel'], 'test');
      expect(messageData0['messages'], isA<List>());
      final messages = List<Message>.from(messageData0['messages'] as List);
      expect(messages[0].name, 'name');
      expect(messages[0].data, 'data4');

      final message1 = manager.publishedMessages[1].message as AblyMessage;
      final messageData1 = message1.message as Map<dynamic, dynamic>;
      expect(messageData1['channel'], 'test');
      expect(messageData1['messages'], isA<List>());
      final messages1 = List<Message>.from(messageData1['messages'] as List);
      expect(messages1[0].name, 'name');
      expect(messages1[0].data, 'data5');
    }, timeout: Timeout.none);
  });
}
