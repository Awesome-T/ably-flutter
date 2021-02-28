import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'provisioning.dart' as provisioning;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum OpState {
  notStarted,
  inProgress,
  succeeded,
  failed,
}

const defaultChannel = 'test-channel';

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _ablyVersion = 'Unknown';
  OpState _provisioningState = OpState.notStarted;
  provisioning.AppKey _appKey;
  OpState _realtimeCreationState = OpState.notStarted;
  OpState _restCreationState = OpState.notStarted;
  ably.Realtime _realtime;
  ably.Rest _rest;
  ably.ConnectionState _realtimeConnectionState;
  ably.ChannelState _realtimeChannelState;
  final _subscriptionsToDispose = <StreamSubscription>[];
  StreamSubscription<ably.Message> _channelMessageSubscription;
  ably.Message channelMessage;
  ably.PaginatedResult<ably.Message> _restHistory;
  ably.PaginatedResult<ably.Message> _realtimeHistory;
  ably.PaginatedResult<ably.PresenceMessage> _restPresenceMembers;
  ably.PaginatedResult<ably.PresenceMessage> _restPresenceHistory;
  List<ably.PresenceMessage> _realtimePresenceMembers;
  ably.PaginatedResult<ably.PresenceMessage> _realtimePresenceHistory;

  //Storing different message types here to be publishable
  List<dynamic> messagesToPublish = [
    null,
    'A simple panda...',
    {
      'I am': null,
      'and': {
        'also': 'nested',
        'too': {'deep': true}
      }
    },
    [
      42,
      {'are': 'you'},
      'ok?',
      false,
      {
        'I am': null,
        'and': {
          'also': 'nested',
          'too': {'deep': true}
        }
      }
    ]
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    // This dispose would not be effective in this example as this is
    // a single view but subscriptions must be disposed when listeners are
    // implemented in the actual application
    //
    // See: https://api.flutter.dev/flutter/widgets/State/dispose.html
    for (final s in _subscriptionsToDispose) {
      s.cancel();
    }
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    print('initPlatformState()');

    String platformVersion;
    String ablyVersion;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ably.platformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    try {
      ablyVersion = await ably.version();
    } on PlatformException {
      ablyVersion = 'Failed to get Ably version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    print('queueing set state');
    setState(() {
      print('set state');
      _platformVersion = platformVersion;
      _ablyVersion = ablyVersion;
    });
  }

  Future<void> provisionAbly() async {
    setState(() {
      _provisioningState = OpState.inProgress;
    });

    provisioning.AppKey appKey;
    try {
      appKey = await provisioning.provision('sandbox-');
      print('App key acquired! `$appKey`');
    } on Exception catch (error) {
      print('Error provisioning Ably: $error');
      setState(() {
        _provisioningState = OpState.failed;
      });
      return;
    }

    setState(() {
      _appKey = appKey;
      _provisioningState = OpState.succeeded;
    });
  }

  Future<void> createAblyRest() async {
    setState(() {
      _restCreationState = OpState.inProgress;
    });

    final clientOptions =
        ably.ClientOptions.fromKey('dBjBRg.vGOaQw:E7zmEdjv0tAVEgZ6')
          ..logLevel = ably.LogLevel.verbose
          ..logHandler = ({msg, exception}) {
            // ignore: avoid_print
            print('Custom logger :: $msg $exception');
          }
        /*..defaultTokenParams = ably.TokenParams(ttl: 20000)*/
        /*..authCallback = (params) async => ably.TokenRequest.fromMap(
            Map.castFrom<dynamic, dynamic, String, dynamic>(
              await provisioning.getTokenRequest(),
            ),
          )*/
        ;

    ably.Rest rest;
    try {
      rest = ably.Rest(options: clientOptions);
    } on Exception catch (error) {
      print('Error creating Ably Rest: $error');
      setState(() {
        _restCreationState = OpState.failed;
      });
      rethrow;
    }

    setState(() {
      _rest = rest;
      _restCreationState = OpState.succeeded;
    });

    const name = 'Hello';
    const dynamic data = 'Flutter';
    // ignore: avoid_print
    print('publishing messages... name "$name", message "$data"');
    try {
      await Future.wait([
        rest.channels.get(defaultChannel).publish(name: name, data: data),
        rest.channels.get(defaultChannel).publish(name: name)
      ]);
      await rest.channels.get(defaultChannel).publish(data: data);
      await rest.channels.get(defaultChannel).publish();
      print('Messages published');
    } on ably.AblyException catch (e) {
      print(e.errorInfo);
    }
    // set state here as handle will have been acquired before calling
    // publish on channels above...
    setState(() {});
  }

  void createAblyRealtime() {
    setState(() {
      _realtimeCreationState = OpState.inProgress;
    });

    final clientOptions = ably.ClientOptions.fromKey(_appKey.toString())
      ..environment = 'sandbox'
      ..logLevel = ably.LogLevel.verbose
      ..autoConnect = false
      ..logHandler = ({msg, exception}) {
        // ignore: avoid_print
        print('Custom logger :: $msg $exception');
      };

    try {
      final realtime = ably.Realtime(options: clientOptions);
      listenRealtimeConnection(realtime);
      final channel = realtime.channels.get(defaultChannel);
      listenRealtimeChannel(channel);
      setState(() {
        _realtime = realtime;
        _realtimeCreationState = OpState.succeeded;
      });
    } on Exception catch (error) {
      print('Error creating Ably Realtime: $error');
      setState(() {
        _realtimeCreationState = OpState.failed;
      });
      rethrow;
    }
  }

  void listenRealtimeConnection(ably.Realtime realtime) {
    final alphaSubscription =
        realtime.connection.on().listen((stateChange) async {
      print('${DateTime.now()}:'
          ' ConnectionStateChange event: ${stateChange.event}'
          '\nReason: ${stateChange.reason}');
      setState(() {
        _realtimeConnectionState = stateChange.current;
      });
    });
    _subscriptionsToDispose.add(alphaSubscription);
  }

  void listenRealtimeChannel(ably.RealtimeChannelInterface channel) {
    final _channelStateChangeSubscription = channel.on().listen((stateChange) {
      print('ChannelStateChange: ${stateChange.current}'
          '\nReason: ${stateChange.reason}');
      setState(() {
        _realtimeChannelState = channel.state;
      });
    });
    _subscriptionsToDispose.add(_channelStateChangeSubscription);
  }

  // https://github.com/dart-lang/sdk/issues/37498
  // ignore: missing_return
  static String opStateDescription(
      OpState state, String action, String operating, String done) {
    switch (state) {
      case OpState.notStarted:
        return action;
      case OpState.inProgress:
        return '$operating...';
      case OpState.succeeded:
        return done;
      case OpState.failed:
        return 'Failed to $action';
    }
  }

  // https://github.com/dart-lang/sdk/issues/37498
  // ignore: missing_return
  static Color opStateColor(OpState state) {
    switch (state) {
      case OpState.notStarted:
        return const Color.fromARGB(255, 192, 192, 255);
      case OpState.inProgress:
        return const Color.fromARGB(255, 192, 192, 192);
      case OpState.succeeded:
        return const Color.fromARGB(255, 128, 255, 128);
      case OpState.failed:
        return const Color.fromARGB(255, 255, 128, 128);
    }
  }

  static Widget button(
    final OpState state,
    void Function() action,
    String actionDescription,
    String operatingDescription,
    String doneDescription,
  ) =>
      FlatButton(
        onPressed: (state == OpState.notStarted || state == OpState.failed)
            ? action
            : null,
        color: opStateColor(state),
        disabledColor: opStateColor(state),
        child: Text(
          opStateDescription(
            state,
            actionDescription,
            operatingDescription,
            doneDescription,
          ),
        ),
      );

  Widget provisionButton() => button(_provisioningState, provisionAbly,
      'Provision Ably', 'Provisioning Ably', 'Ably Provisioned');

  Widget createRestButton() => button(_restCreationState, createAblyRest,
      'Create Ably Rest', 'Create Ably Rest', 'Ably Rest Created');

  Widget createRealtimeButton() => button(
      _realtimeCreationState,
      createAblyRealtime,
      'Create Ably Realtime',
      'Creating Ably Realtime',
      'Ably Realtime Created');

  Widget createRTCConnectButton() => FlatButton(
        padding: EdgeInsets.zero,
        onPressed: _realtime?.connect,
        child: const Text('Connect'),
      );

  Widget createRTCloseButton() => FlatButton(
        padding: EdgeInsets.zero,
        onPressed: (_realtimeConnectionState == ably.ConnectionState.connected)
            ? _realtime?.close
            : null,
        child: const Text('Close Connection'),
      );

  Widget createChannelAttachButton() => FlatButton(
        padding: EdgeInsets.zero,
        onPressed: (_realtimeConnectionState == ably.ConnectionState.connected)
            ? () async {
                final channel = _realtime.channels.get(defaultChannel);
                print('Attaching to channel ${channel.name}.'
                    ' Current state ${channel.state}.');
                try {
                  await channel.attach();
                } on ably.AblyException catch (e) {
                  print('Unable to attach to channel: ${e.errorInfo}');
                }
              }
            : null,
        child: const Text('Attach to Channel'),
      );

  Widget createChannelDetachButton() => FlatButton(
        padding: EdgeInsets.zero,
        onPressed: (_realtimeChannelState == ably.ChannelState.attached)
            ? () {
                final channel = _realtime.channels.get(defaultChannel);
                print('Detaching from channel ${channel.name}.'
                    ' Current state ${channel.state}.');
                channel.detach();
                print('Detached');
              }
            : null,
        child: const Text('Detach from channel'),
      );

  Widget createChannelSubscribeButton() => FlatButton(
        onPressed: (_realtimeChannelState == ably.ChannelState.attached &&
                _channelMessageSubscription == null)
            ? () {
                final channel = _realtime.channels.get(defaultChannel);
                final messageStream =
                    channel.subscribe(names: ['message-data', 'Hello']);
                _channelMessageSubscription = messageStream.listen((message) {
                  print('Channel message received: $message\n'
                      '\tisNull: ${message.data == null}\n'
                      '\tisString ${message.data is String}\n'
                      '\tisMap ${message.data is Map}\n'
                      '\tisList ${message.data is List}\n');
                  setState(() {
                    channelMessage = message;
                  });
                });
                print('Channel messages subscribed');
                _subscriptionsToDispose.add(_channelMessageSubscription);
              }
            : null,
        child: const Text('Subscribe'),
      );

  Widget createChannelUnSubscribeButton() => FlatButton(
        onPressed: (_channelMessageSubscription != null)
            ? () async {
                await _channelMessageSubscription.cancel();
                print('Channel messages unsubscribed');
                setState(() {
                  _channelMessageSubscription = null;
                });
              }
            : null,
        child: const Text('Unsubscribe'),
      );

  int typeCounter = 0;
  int realtimePubCounter = 0;

  Widget createChannelPublishButton() => FlatButton(
        onPressed: (_realtimeChannelState == ably.ChannelState.attached)
            ? () async {
                print('Sending rest message...');
                final data = messagesToPublish[
                    (realtimePubCounter++ % messagesToPublish.length)];
                final m = ably.Message(name: 'Hello', data: data);
                try {
                  switch (typeCounter % 3) {
                    case 0:
                      await _realtime.channels
                          .get(defaultChannel)
                          .publish(name: 'Hello', data: data);
                      break;
                    case 1:
                      await _realtime.channels
                          .get(defaultChannel)
                          .publish(message: m);
                      break;
                    case 2:
                      await _realtime.channels
                          .get(defaultChannel)
                          .publish(messages: [m, m]);
                  }
                  if (realtimePubCounter != 0 &&
                      realtimePubCounter % messagesToPublish.length == 0) {
                    typeCounter++;
                  }
                  print('Realtime message sent.');
                  setState(() {});
                } on ably.AblyException catch (e) {
                  print(e);
                }
              }
            : null,
        color: Colors.yellow,
        child: Text(
          'Publish: '
          '${messagesToPublish[realtimePubCounter % messagesToPublish.length]}',
        ),
      );

  int msgCounter = 1;

  Widget sendRestMessage() => FlatButton(
        onPressed: (_rest == null)
            ? null
            : () async {
                print('Sending rest message');
                try {
                  await _rest.channels
                      .get(defaultChannel)
                      .publish(name: 'Hello', data: 'Flutter $msgCounter');
                  print('Rest message sent.');
                  setState(() {
                    ++msgCounter;
                  });
                } on ably.AblyException catch (e) {
                  print('Rest message sending failed:: $e :: ${e.errorInfo}');
                }
              },
        color: Colors.yellow,
        child: const Text('Publish'),
      );

  Widget getPageNavigator<T>({
    String name,
    bool enabled,
    ably.PaginatedResult<T> page,
    Future<ably.PaginatedResult<T>> Function() query,
    Function(ably.PaginatedResult<T> result) onUpdate,
  }) =>
      FlatButton(
        onPressed: !enabled
            ? null
            : () async {
                final next = page?.hasNext() ?? false;
                print('$name: getting ${next ? 'next' : 'first'} page');
                try {
                  if (page == null || page.items.isEmpty) {
                    onUpdate(await query());
                  } else if (next) {
                    onUpdate(await page.next());
                  } else {
                    onUpdate(await page.first());
                  }
                } on ably.AblyException catch (e) {
                  print('failed to get $name:: $e :: ${e.errorInfo}');
                }
              },
        onLongPress: !enabled
            ? null
            : () async {
                onUpdate(await query());
              },
        color: Colors.yellow,
        child: Text('Get $name'),
      );

  Widget getRestChannelHistory() => getPageNavigator<ably.Message>(
      name: 'Rest history',
      enabled: _rest != null,
      page: _restHistory,
      query: () async =>
          _rest.channels.get(defaultChannel).history(ably.RestHistoryParams(
                direction: 'forwards',
                limit: 10,
              )),
      onUpdate: (result) {
        setState(() {
          _restHistory = result;
        });
      });

  Widget getRestChannelPresence() => getPageNavigator<ably.PresenceMessage>(
      name: 'Rest presence members',
      enabled: _rest != null,
      page: _restPresenceMembers,
      query: () async => _rest.channels
          .get(defaultChannel)
          .presence
          .get(ably.RestPresenceParams(limit: 10)),
      onUpdate: (result) {
        setState(() {
          _restPresenceMembers = result;
        });
      });

  Widget getRestChannelPresenceHistory() =>
    getPageNavigator<ably.PresenceMessage>(
      name: 'Rest presence history',
      enabled: _rest != null,
      page: _restPresenceHistory,
      query: () async => _rest.channels
        .get(defaultChannel)
        .presence
        .history(ably.RestHistoryParams(limit: 10)),
      onUpdate: (result) {
        setState(() {
          _restPresenceHistory = result;
        });
      });

  Widget getRealtimeChannelHistory() => getPageNavigator<ably.Message>(
    name: 'Realtime history',
    enabled: _realtime != null,
    page: _realtimeHistory,
    query: () async => _realtime.channels.get(defaultChannel).history(
      ably.RealtimeHistoryParams(
        limit: 10,
        untilAttach: true,
      ),
    ),
    onUpdate: (result) {
      setState(() {
        _realtimeHistory = result;
      });
    });

  Widget getRealtimeChannelPresence() => FlatButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                _realtimePresenceMembers = await _realtime.channels
                    .get(defaultChannel)
                    .presence
                    .get(ably.RealtimePresenceParams());
                setState(() {});
              },
        color: Colors.yellow,
        child: const Text('Get Realtime presence members'),
      );

  Widget getRealtimeChannelPresenceHistory() =>
      getPageNavigator<ably.PresenceMessage>(
          name: 'Realtime presence history',
          enabled: _realtime != null,
          page: _realtimePresenceHistory,
          query: () async => _realtime.channels
              .get(defaultChannel)
              .presence
              .history(ably.RealtimeHistoryParams(limit: 10)),
          onUpdate: (result) {
            setState(() {
              _realtimePresenceHistory = result;
            });
          });

  final List _presenceData = [
    null,
    1,
    'hello',
    {'a': 'b'},
    [
      1,
      'ably',
      null,
      {'a': 'b'}
    ],
    {
      'c': ['a', 'b']
    },
  ];

  int _presenceDataIncrementer = 0;

  Object get _nextPresenceData =>
      _presenceData[_presenceDataIncrementer++ % _presenceData.length];

  Object get _currentPresenceData => (_presenceDataIncrementer == 0)
      ? null
      : _presenceData[_presenceDataIncrementer - 1 % _presenceData.length];

  Widget enterRealtimePresence() => FlatButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime.channels
                    .get(defaultChannel)
                    .presence
                    .enterClient('33', _nextPresenceData);
                setState(() {});
              },
        color: Colors.yellow,
        child: const Text('Enter'),
      );

  Widget updateRealtimePresence() => FlatButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime.channels
                    .get(defaultChannel)
                    .presence
                    .updateClient('33', _nextPresenceData);
                setState(() {});
              },
        color: Colors.yellow,
        child: const Text('Update'),
      );

  Widget leaveRealtimePresence() => FlatButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime.channels
                    .get(defaultChannel)
                    .presence
                    .leaveClient('33', _nextPresenceData);
                setState(() {});
              },
        color: Colors.yellow,
        child: const Text('Leave'),
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Ably Plugin Example App'),
          ),
          body: Center(
            child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                children: [
                  const Text(
                    'System Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Running on: $_platformVersion\n'),
                  Text('Ably version: $_ablyVersion\n'),
                  provisionButton(),
                  Text(
                    'App Key:'
                    ' ${_appKey?.toString() ?? 'Ably not provisioned yet.'}',
                  ),
                  const Divider(),
                  const Text(
                    'Realtime',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  createRealtimeButton(),
                  Text(
                    'Realtime:'
                    ' ${_realtime?.toString() ?? 'Realtime not created yet.'}',
                  ),
                  Text('Connection State: $_realtimeConnectionState'),
                  Text('Channel State: $_realtimeChannelState'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: createRTCConnectButton(),
                      ),
                      Expanded(
                        child: createRTCloseButton(),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: createChannelAttachButton()),
                      Expanded(child: createChannelDetachButton()),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: createChannelSubscribeButton()),
                      Expanded(child: createChannelUnSubscribeButton()),
                    ],
                  ),
                  const Text(
                    'Channel Messages',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('Message from channel: ${channelMessage?.data ?? '-'}'),
                  createChannelPublishButton(),
                  getRealtimeChannelHistory(),
                  ..._realtimeHistory?.items
                          ?.map((m) => Text('${m.name}:${m.data?.toString()}'))
                          ?.toList() ??
                      [],
                  const Text(
                    'Presence',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text('Current Data: $_currentPresenceData'),
                  Row(
                    children: [
                      Expanded(
                        child: enterRealtimePresence(),
                      ),
                      Expanded(
                        child: updateRealtimePresence(),
                      ),
                      Expanded(
                        child: leaveRealtimePresence(),
                      ),
                    ],
                  ),
                  getRealtimeChannelPresence(),
                  ..._realtimePresenceMembers
                          ?.map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
                          ?.toList() ??
                      [],
                  getRealtimeChannelPresenceHistory(),
                  ..._realtimePresenceHistory?.items
                          ?.map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
                          ?.toList() ??
                      [],
                  const Divider(),
                  const Text(
                    'Rest',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  createRestButton(),
                  Text('Rest: '
                      '${_rest?.toString() ?? 'Ably Rest not created yet.'}'),
                  sendRestMessage(),
                  Text(
                    'Rest: press this button to publish a new message with'
                    ' data "Flutter $msgCounter"',
                  ),
                  getRestChannelHistory(),
                  ..._restHistory?.items
                          ?.map((m) => Text('${m.name}:${m.data?.toString()}'))
                          ?.toList() ??
                      [],
                  getRestChannelPresence(),
                  ..._restPresenceMembers?.items
                          ?.map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
                          ?.toList() ??
                      [],
                  getRestChannelPresenceHistory(),
                  ..._restPresenceHistory?.items
                          ?.map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
                          ?.toList() ??
                      [],
                ]),
          ),
        ),
      );
}
