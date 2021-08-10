//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

// ignore_for_file: public_member_api_docs

class CodecTypes {
  static const int ablyMessage = 128;
  static const int ablyEventMessage = 129;
  static const int clientOptions = 130;
  static const int messageData = 131;
  static const int messageExtras = 132;
  static const int message = 133;
  static const int tokenParams = 134;
  static const int tokenDetails = 135;
  static const int tokenRequest = 136;
  static const int restChannelOptions = 137;
  static const int realtimeChannelOptions = 138;
  static const int paginatedResult = 139;
  static const int restHistoryParams = 140;
  static const int realtimeHistoryParams = 141;
  static const int restPresenceParams = 142;
  static const int presenceMessage = 143;
  static const int realtimePresenceParams = 144;
  static const int deviceDetails = 145;
  static const int localDevice = 146;
  static const int pushChannelSubscription = 147;
  static const int errorInfo = 148;
  static const int connectionStateChange = 149;
  static const int channelStateChange = 150;
}

class PlatformMethod {
  static const String getPlatformVersion = 'getPlatformVersion';
  static const String getVersion = 'getVersion';
  static const String registerAbly = 'registerAbly';
  static const String authCallback = 'authCallback';
  static const String realtimeAuthCallback = 'realtimeAuthCallback';
  static const String createRestWithOptions = 'createRestWithOptions';
  static const String setRestChannelOptions = 'setRestChannelOptions';
  static const String publish = 'publish';
  static const String restHistory = 'restHistory';
  static const String restPresenceGet = 'restPresenceGet';
  static const String restPresenceHistory = 'restPresenceHistory';
  static const String releaseRestChannel = 'releaseRestChannel';
  static const String createRealtimeWithOptions = 'createRealtimeWithOptions';
  static const String connectRealtime = 'connectRealtime';
  static const String closeRealtime = 'closeRealtime';
  static const String attachRealtimeChannel = 'attachRealtimeChannel';
  static const String detachRealtimeChannel = 'detachRealtimeChannel';
  static const String setRealtimeChannelOptions = 'setRealtimeChannelOptions';
  static const String realtimePresenceGet = 'realtimePresenceGet';
  static const String realtimePresenceHistory = 'realtimePresenceHistory';
  static const String realtimePresenceEnter = 'realtimePresenceEnter';
  static const String realtimePresenceUpdate = 'realtimePresenceUpdate';
  static const String realtimePresenceLeave = 'realtimePresenceLeave';
  static const String onRealtimePresenceMessage = 'onRealtimePresenceMessage';
  static const String publishRealtimeChannelMessage =
      'publishRealtimeChannelMessage';
  static const String releaseRealtimeChannel = 'releaseRealtimeChannel';
  static const String realtimeHistory = 'realtimeHistory';
  static const String pushActivate = 'pushActivate';
  static const String pushDeactivate = 'pushDeactivate';
  static const String pushSubscribeDevice = 'pushSubscribeDevice';
  static const String pushUnsubscribeDevice = 'pushUnsubscribeDevice';
  static const String pushSubscribeClient = 'pushSubscribeClient';
  static const String pushUnsubscribeClient = 'pushUnsubscribeClient';
  static const String pushListSubscriptions = 'pushListSubscriptions';
  static const String pushDevice = 'pushDevice';
  static const String pushRequestNotificationPermission =
      'pushRequestNotificationPermission';
  static const String onRealtimeConnectionStateChanged =
      'onRealtimeConnectionStateChanged';
  static const String onRealtimeChannelStateChanged =
      'onRealtimeChannelStateChanged';
  static const String onRealtimeChannelMessage = 'onRealtimeChannelMessage';
  static const String nextPage = 'nextPage';
  static const String firstPage = 'firstPage';
}

class TxTransportKeys {
  static const String channelName = 'channelName';
  static const String params = 'params';
  static const String data = 'data';
  static const String clientId = 'clientId';
  static const String options = 'options';
  static const String messages = 'messages';
}

class TxAblyMessage {
  static const String registrationHandle = 'registrationHandle';
  static const String type = 'type';
  static const String message = 'message';
}

class TxAblyEventMessage {
  static const String eventName = 'eventName';
  static const String type = 'type';
  static const String message = 'message';
}

class TxErrorInfo {
  static const String code = 'code';
  static const String message = 'message';
  static const String statusCode = 'statusCode';
  static const String href = 'href';
  static const String requestId = 'requestId';
  static const String cause = 'cause';
}

class TxMessageData {
  static const String data = 'data';
  static const String type = 'type';
}

class TxDeltaExtras {
  static const String format = 'format';
  static const String from = 'from';
}

class TxMessageExtras {
  static const String extras = 'extras';
  static const String delta = 'delta';
}

class TxClientOptions {
  static const String authUrl = 'authUrl';
  static const String authMethod = 'authMethod';
  static const String key = 'key';
  static const String tokenDetails = 'tokenDetails';
  static const String authHeaders = 'authHeaders';
  static const String authParams = 'authParams';
  static const String queryTime = 'queryTime';
  static const String useTokenAuth = 'useTokenAuth';
  static const String hasAuthCallback = 'hasAuthCallback';
  static const String clientId = 'clientId';
  static const String logLevel = 'logLevel';
  static const String tls = 'tls';
  static const String restHost = 'restHost';
  static const String realtimeHost = 'realtimeHost';
  static const String port = 'port';
  static const String tlsPort = 'tlsPort';
  static const String autoConnect = 'autoConnect';
  static const String useBinaryProtocol = 'useBinaryProtocol';
  static const String queueMessages = 'queueMessages';
  static const String echoMessages = 'echoMessages';
  static const String recover = 'recover';
  static const String environment = 'environment';
  static const String idempotentRestPublishing = 'idempotentRestPublishing';
  static const String httpOpenTimeout = 'httpOpenTimeout';
  static const String httpRequestTimeout = 'httpRequestTimeout';
  static const String httpMaxRetryCount = 'httpMaxRetryCount';
  static const String realtimeRequestTimeout = 'realtimeRequestTimeout';
  static const String fallbackHosts = 'fallbackHosts';
  static const String fallbackHostsUseDefault = 'fallbackHostsUseDefault';
  static const String fallbackRetryTimeout = 'fallbackRetryTimeout';
  static const String defaultTokenParams = 'defaultTokenParams';
  static const String channelRetryTimeout = 'channelRetryTimeout';
  static const String transportParams = 'transportParams';
}

class TxRestChannelOptions {
  static const String cipher = 'cipher';
}

class TxRealtimeChannelOptions {
  static const String cipher = 'cipher';
  static const String params = 'params';
  static const String modes = 'modes';
}

class TxTokenDetails {
  static const String token = 'token';
  static const String expires = 'expires';
  static const String issued = 'issued';
  static const String capability = 'capability';
  static const String clientId = 'clientId';
}

class TxTokenParams {
  static const String capability = 'capability';
  static const String clientId = 'clientId';
  static const String nonce = 'nonce';
  static const String timestamp = 'timestamp';
  static const String ttl = 'ttl';
}

class TxTokenRequest {
  static const String capability = 'capability';
  static const String clientId = 'clientId';
  static const String keyName = 'keyName';
  static const String mac = 'mac';
  static const String nonce = 'nonce';
  static const String timestamp = 'timestamp';
  static const String ttl = 'ttl';
}

class TxEnumConstants {
  static const String initialized = 'initialized';
  static const String connecting = 'connecting';
  static const String connected = 'connected';
  static const String disconnected = 'disconnected';
  static const String attaching = 'attaching';
  static const String attached = 'attached';
  static const String detaching = 'detaching';
  static const String detached = 'detached';
  static const String suspended = 'suspended';
  static const String closing = 'closing';
  static const String closed = 'closed';
  static const String failed = 'failed';
  static const String absent = 'absent';
  static const String leave = 'leave';
  static const String enter = 'enter';
  static const String present = 'present';
  static const String update = 'update';
  static const String presence = 'presence';
  static const String publish = 'publish';
  static const String subscribe = 'subscribe';
  static const String presenceSubscribe = 'presenceSubscribe';
}

class TxFormFactorEnum {
  static const String phone = 'phone';
  static const String tablet = 'tablet';
  static const String desktop = 'desktop';
  static const String tv = 'tv';
  static const String watch = 'watch';
  static const String car = 'car';
  static const String embedded = 'embedded';
  static const String other = 'other';
}

class TxDevicePlatformEnum {
  static const String ios = 'ios';
  static const String android = 'android';
  static const String browser = 'browser';
}

class TxDevicePushStateEnum {
  static const String active = 'active';
  static const String failing = 'failing';
  static const String failed = 'failed';
}

class TxConnectionStateChange {
  static const String current = 'current';
  static const String previous = 'previous';
  static const String event = 'event';
  static const String retryIn = 'retryIn';
  static const String reason = 'reason';
}

class TxChannelStateChange {
  static const String current = 'current';
  static const String previous = 'previous';
  static const String event = 'event';
  static const String resumed = 'resumed';
  static const String reason = 'reason';
}

class TxMessage {
  static const String id = 'id';
  static const String timestamp = 'timestamp';
  static const String clientId = 'clientId';
  static const String connectionId = 'connectionId';
  static const String encoding = 'encoding';
  static const String data = 'data';
  static const String name = 'name';
  static const String extras = 'extras';
}

class TxPresenceMessage {
  static const String id = 'id';
  static const String action = 'action';
  static const String clientId = 'clientId';
  static const String connectionId = 'connectionId';
  static const String data = 'data';
  static const String encoding = 'encoding';
  static const String extras = 'extras';
  static const String timestamp = 'timestamp';
}

class TxPaginatedResult {
  static const String items = 'items';
  static const String type = 'type';
  static const String hasNext = 'hasNext';
}

class TxRestHistoryParams {
  static const String start = 'start';
  static const String end = 'end';
  static const String direction = 'direction';
  static const String limit = 'limit';
}

class TxRealtimeHistoryParams {
  static const String start = 'start';
  static const String end = 'end';
  static const String direction = 'direction';
  static const String limit = 'limit';
  static const String untilAttach = 'untilAttach';
}

class TxRestPresenceParams {
  static const String limit = 'limit';
  static const String clientId = 'clientId';
  static const String connectionId = 'connectionId';
}

class TxRealtimePresenceParams {
  static const String waitForSync = 'waitForSync';
  static const String clientId = 'clientId';
  static const String connectionId = 'connectionId';
}

class TxDeviceDetails {
  static const String id = 'id';
  static const String clientId = 'clientId';
  static const String platform = 'platform';
  static const String formFactor = 'formFactor';
  static const String metadata = 'metadata';
  static const String devicePushDetails = 'devicePushDetails';
}

class TxDevicePushDetails {
  static const String recipient = 'recipient';
  static const String state = 'state';
  static const String errorReason = 'errorReason';
}

class TxLocalDevice {
  static const String deviceSecret = 'deviceSecret';
  static const String deviceIdentityToken = 'deviceIdentityToken';
}

class TxPushChannelSubscription {
  static const String channel = 'channel';
  static const String deviceId = 'deviceId';
  static const String clientId = 'clientId';
}

class TxPushRequestNotificationPermission {
  static const String provisionalPermissionRequest = 'provisionalPermissionRequest';
}
