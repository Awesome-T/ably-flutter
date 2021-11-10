import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/provisioning.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/rest.dart';

final logMessages = <List<String?>>[];

ClientOptions getClientOptions(
  String appKey, [
  String clientId = 'someClientId',
]) =>
    ClientOptions.fromKey(appKey)
      ..environment = 'sandbox'
      ..clientId = clientId
      ..logLevel = LogLevel.verbose
      ..logHandler =
          ({msg, exception}) => logMessages.add([msg, exception.toString()]);

Future<Map<String, dynamic>> testRestPresenceGet({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = (await provision('sandbox-')).toString();

  final rest = Rest(options: getClientOptions(appKey));
  final channel = rest.channels.get('test');
  final membersInitial = await getPresenceMembers(channel);

  // enter multiple clients
  for (var i = 0; i < messagesToPublish.length; i++) {
    await Realtime(
      options: getClientOptions(appKey, 'client-$i'),
    ).channels.get('test').presence.enter(messagesToPublish[i][1]);
  }

  await Future.delayed(TestConstants.publishToHistoryDelay);

  final membersDefault = await getPresenceMembers(channel);
  await Future.delayed(TestConstants.publishToHistoryDelay);

  final membersLimit4 = await getPresenceMembers(
    channel,
    RestPresenceParams(limit: 4),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  final membersLimit2 = await getPresenceMembers(
    channel,
    RestPresenceParams(limit: 2),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  final membersClientId = await getPresenceMembers(
    channel,
    RestPresenceParams(clientId: 'client-1'),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // TODO(tiholic) extract connection ID from realtime instance
  //  after implementing `id` update on connection object from platform
  // Until then, `membersConnectionId` will be empty list
  final membersConnectionId = await getPresenceMembers(
    channel,
    RestPresenceParams(connectionId: 'connection-1'),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  return {
    'handle': await rest.handle,
    'membersInitial': membersInitial,
    'membersDefault': membersDefault,
    'membersLimit4': membersLimit4,
    'membersLimit2': membersLimit2,
    'membersClientId': membersClientId,
    'membersConnectionId': membersConnectionId,
    'log': logMessages,
  };
}
