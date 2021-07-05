///Transmission protocol custom types. Will be used by codecs
Iterable<Map<String, dynamic>> get _types sync* {
  // Add a new key to create a new constant (containing integer) in CodecTypes
  // which can be used to identify the type of a serialized buffer.
  const platformTypes = <String>[
    // Ably flutter plugin protocol message
    'ablyMessage',
    'ablyEventMessage',
    //Other ably objects
    'clientOptions',
    'messageData',
    'messageExtras',
    'message',
    'tokenParams',
    'tokenDetails',
    'tokenRequest',
    'restChannelOptions',
    'realtimeChannelOptions',
    'paginatedResult',
    'restHistoryParams',
    'realtimeHistoryParams',
    'restPresenceParams',
    'presenceMessage',
    'realtimePresenceParams',

    // Push Notifications
    'deviceDetails',

    'errorInfo',

    // Events
    'connectionStateChange',
    'channelStateChange',
  ];

  // Custom type values must be over 127. At the time of writing
  // the standard message codec encodes them as an unsigned byte
  // which means the maximum type value is 255. If we get to the
  // point of having more than that number of custom types (i.e.
  // more than 128 [255 - 127]) then we can either roll our own
  // codec from scratch or, perhaps easier, reserve custom type
  // value 255 to indicate that it will be followed by a subtype
  // value - perhaps of a wider type.
  //
  // https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html
  var index = 128;
  for (final platformType in platformTypes) {
    yield {'name': platformType, 'value': index++};
  }
}

/// Platform method names
///
/// The name is variable/ symbol name, and the value is the string value
const List<Map<String, String>> _platformMethods = [
  {'name': 'getPlatformVersion', 'value': 'getPlatformVersion'},
  {'name': 'getVersion', 'value': 'getVersion'},
  {'name': 'registerAbly', 'value': 'registerAbly'},

  // Auth
  {'name': 'authCallback', 'value': 'authCallback'},
  {'name': 'realtimeAuthCallback', 'value': 'realtimeAuthCallback'},

  // Rest
  {'name': 'createRestWithOptions', 'value': 'createRestWithOptions'},
  {'name': 'setRestChannelOptions', 'value': 'setRestChannelOptions'},
  {'name': 'publish', 'value': 'publish'},
  {'name': 'restHistory', 'value': 'restHistory'},
  {'name': 'restPresenceGet', 'value': 'restPresenceGet'},
  {'name': 'restPresenceHistory', 'value': 'restPresenceHistory'},
  {'name': 'releaseRestChannel', 'value': 'releaseRestChannel'},

  // Realtime
  {'name': 'createRealtimeWithOptions', 'value': 'createRealtimeWithOptions'},
  {'name': 'connectRealtime', 'value': 'connectRealtime'},
  {'name': 'closeRealtime', 'value': 'closeRealtime'},
  {'name': 'attachRealtimeChannel', 'value': 'attachRealtimeChannel'},
  {'name': 'detachRealtimeChannel', 'value': 'detachRealtimeChannel'},
  {'name': 'setRealtimeChannelOptions', 'value': 'setRealtimeChannelOptions'},
  {'name': 'realtimePresenceGet', 'value': 'realtimePresenceGet'},
  {'name': 'realtimePresenceHistory', 'value': 'realtimePresenceHistory'},
  {'name': 'realtimePresenceEnter', 'value': 'realtimePresenceEnter'},
  {'name': 'realtimePresenceUpdate', 'value': 'realtimePresenceUpdate'},
  {'name': 'realtimePresenceLeave', 'value': 'realtimePresenceLeave'},
  {'name': 'onRealtimePresenceMessage', 'value': 'onRealtimePresenceMessage'},

  // Push Notifications
  {'name': 'pushActivate', 'value': 'pushActivate' },
  {'name': 'pushDeactivate', 'value': 'pushDeactivate' },
  {'name': 'pushSubscribe', 'value': 'pushSubscribe' },
  {'name': 'pushUnsubscribe', 'value': 'pushUnsubscribe' },

  {
    'name': 'publishRealtimeChannelMessage',
    'value': 'publishRealtimeChannelMessage'
  },
  {'name': 'releaseRealtimeChannel', 'value': 'releaseRealtimeChannel'},
  {'name': 'realtimeHistory', 'value': 'realtimeHistory'},

  // Realtime events
  {
    'name': 'onRealtimeConnectionStateChanged',
    'value': 'onRealtimeConnectionStateChanged'
  },
  {
    'name': 'onRealtimeChannelStateChanged',
    'value': 'onRealtimeChannelStateChanged'
  },
  {'name': 'onRealtimeChannelMessage', 'value': 'onRealtimeChannelMessage'},

  // Paginated results
  {'name': 'nextPage', 'value': 'nextPage'},
  {'name': 'firstPage', 'value': 'firstPage'},
];

const List<Map<String, dynamic>> _objects = [
  // TransportKeys exist to synchronize the string constants used in data
  // structures sent between platforms. For example, you can see
  // usages of [TxTransportKeys.channelName]
  {
    'name': 'TransportKeys',
    'properties': <String>[
      'channelName',
      'params',
      'data',
      'clientId',
      'options',
      'messages',
    ]
  },
  {
    'name': 'AblyMessage',
    'properties': <String>['registrationHandle', 'type', 'message']
  },
  {
    'name': 'AblyEventMessage',
    'properties': <String>['eventName', 'type', 'message']
  },
  {
    'name': 'MessageData',
    'properties': <String>['data', 'type']
  },
  {
    'name': 'DeltaExtras',
    'properties': <String>['format', 'from']
  },
  {
    'name': 'MessageExtras',
    'properties': <String>['extras', 'delta']
  },
  {
    'name': 'ClientOptions',
    'properties': <String>[
      // Auth options
      'authUrl',
      'authMethod',
      'key',
      'tokenDetails',
      'authHeaders',
      'authParams',
      'queryTime',
      'useTokenAuth',
      'hasAuthCallback',
      // ClientOptions
      'clientId',
      'logLevel',
      'tls',
      'restHost',
      'realtimeHost',
      'port',
      'tlsPort',
      'autoConnect',
      'useBinaryProtocol',
      'queueMessages',
      'echoMessages',
      'recover',
      'environment',
      'idempotentRestPublishing',
      'httpOpenTimeout',
      'httpRequestTimeout',
      'httpMaxRetryCount',
      'realtimeRequestTimeout',
      'fallbackHosts',
      'fallbackHostsUseDefault',
      'fallbackRetryTimeout',
      'defaultTokenParams',
      'channelRetryTimeout',
      'transportParams',
    ]
  },
  {
    'name': 'RestChannelOptions',
    'properties': <String>['cipher']
  },
  {
    'name': 'RealtimeChannelOptions',
    'properties': <String>[
      'cipher',
      'params',
      'modes',
    ]
  },
  {
    'name': 'TokenDetails',
    'properties': <String>[
      'token',
      'expires',
      'issued',
      'capability',
      'clientId'
    ]
  },
  {
    'name': 'TokenParams',
    'properties': <String>[
      'capability',
      'clientId',
      'nonce',
      'timestamp',
      'ttl'
    ]
  },
  {
    'name': 'TokenRequest',
    'properties': <String>[
      'capability',
      'clientId',
      'keyName',
      'mac',
      'nonce',
      'timestamp',
      'ttl'
    ]
  },
  {
    'name': 'EnumConstants',
    'properties': <String>[
      // connection & channel - states & events
      'initialized',
      'connecting',
      'connected',
      'disconnected',
      'attaching',
      'attached',
      'detaching',
      'detached',
      'suspended',
      'closing',
      'closed',
      'failed',
      // Presence actions
      'absent',
      'leave',
      'enter',
      'present',
      'update',
      // channel modes
      'presence',
      'publish',
      'subscribe',
      'presenceSubscribe',
    ]
  },
  {
    'name': 'Message',
    'properties': <String>[
      'id',
      'timestamp',
      'clientId',
      'connectionId',
      'encoding',
      'data',
      'name',
      'extras'
    ]
  },
  {
    'name': 'PresenceMessage',
    'properties': <String>[
      'id',
      'action',
      'clientId',
      'connectionId',
      'data',
      'encoding',
      'extras',
      'timestamp',
    ]
  },
  {
    'name': 'PaginatedResult',
    'properties': <String>['items', 'type', 'hasNext']
  },
  {
    'name': 'RestHistoryParams',
    'properties': <String>[
      'start',
      'end',
      'direction',
      'limit',
    ]
  },
  {
    'name': 'RealtimeHistoryParams',
    'properties': <String>[
      'start',
      'end',
      'direction',
      'limit',
      'untilAttach',
    ]
  },
  {
    'name': 'RestPresenceParams',
    'properties': <String>[
      'limit',
      'clientId',
      'connectionId',
    ]
  },
  {
    'name': 'RealtimePresenceParams',
    'properties': <String>[
      'waitForSync',
      'clientId',
      'connectionId',
    ]
  },
  {
    'name': 'DeviceDetails',
    'properties': <String>[
      'id',
      'platform',
      'formFactor',
      'clientId',
      'metadata'
    ]
  },
  {
    'name': 'ErrorInfo',
    'properties': <String>[
      'code',
      'message',
      'statusCode',
      'href',
      'requestId',
      'cause'
    ]
  },
  {
    'name': 'ConnectionStateChange',
    'properties': <String>['current', 'previous', 'event', 'retryIn', 'reason']
  },
  {
    'name': 'ChannelStateChange',
    'properties': <String>['current', 'previous', 'event', 'resumed', 'reason']
  },
];

// exporting all the constants as a single map
// which can be directly fed to template as context
Map<String, dynamic> context = {
  'types': _types,
  'methods': _platformMethods,
  'objects': _objects
};
