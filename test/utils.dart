import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/impl/message.dart';
import 'package:ably_flutter/src/method_call_handler.dart';
import 'package:ably_flutter/src/platform.dart' as platform;
import 'package:flutter/services.dart';

typedef MethodCallHandler = Future<dynamic> Function(MethodCall);

class MockMethodCallManager {
  int handleCounter = 0;
  bool isAuthenticated = false;
  final channels = <int, AblyMessage>{};
  final publishedMessages = <AblyMessage>[];
  final methodChannel = platform.methodChannel;

  MockMethodCallManager() {
    methodChannel.setMockMethodCallHandler(handler);
  }

  void reset() {
    channels.clear();
    publishedMessages.clear();
    handleCounter = 0;
    methodChannel.setMockMethodCallHandler(null);
  }

  Future<dynamic> handler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case PlatformMethod.registerAbly:
        return true;

      case PlatformMethod.createRestWithOptions:
      case PlatformMethod.createRealtimeWithOptions:
        final handle = ++handleCounter;
        channels[handle] = methodCall.arguments as AblyMessage;
        return handle;

      case PlatformMethod.publish:
        final message = methodCall.arguments as AblyMessage;
        final handle = (message.message as AblyMessage).handle;
        final ablyChannel = channels[handle];
        final clientOptions = ablyChannel.message as ClientOptions;

        // `authUrl` is used to indicate the presence of an authCallback,
        // because function references (in `authCallback`) get dropped by the
        // PlatformChannel.
        if (!isAuthenticated && clientOptions.authUrl == 'hasAuthCallback') {
          await AblyMethodCallHandler(methodChannel).onAuthCallback(
            AblyMessage(
              TokenParams(timestamp: DateTime.now()),
              handle: handle,
            ),
          );
          isAuthenticated = true;
          throw PlatformException(
            code: ErrorCodes.authCallbackFailure.toString(),
          );
        }

        publishedMessages.add(message);
        return null;

      case PlatformMethod.publishRealtimeChannelMessage:
        final message = methodCall.arguments as AblyMessage;
        final handle = (message.message as AblyMessage).handle;
        final ablyChannel = channels[handle];
        final clientOptions = ablyChannel.message as ClientOptions;

        // `authUrl` is used to indicate the presence of an authCallback,
        // because function references (in `authCallback`) get dropped by the
        // PlatformChannel.
        if (!isAuthenticated && clientOptions.authUrl == 'hasAuthCallback') {
          await AblyMethodCallHandler(methodChannel).onRealtimeAuthCallback(
            AblyMessage(TokenParams(timestamp: DateTime.now()),
              handle: handle));
          isAuthenticated = true;
          throw PlatformException(
            code: ErrorCodes.authCallbackFailure.toString());
        }

        publishedMessages.add(message);
        return null;

      default:
        return throw Exception('Unexpected method call: ${methodCall.method}'
          ' args: ${methodCall.arguments}');
    }
  }
}
