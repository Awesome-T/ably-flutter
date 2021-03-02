//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

@import Foundation;

typedef NS_ENUM(UInt8, _Value) {
    ablyMessageCodecType = 128,
    ablyEventMessageCodecType = 129,
    clientOptionsCodecType = 130,
    messageDataCodecType = 131,
    messageCodecType = 132,
    tokenParamsCodecType = 133,
    tokenDetailsCodecType = 134,
    tokenRequestCodecType = 135,
    paginatedResultCodecType = 136,
    restHistoryParamsCodecType = 137,
    realtimeHistoryParamsCodecType = 138,
    restPresenceParamsCodecType = 139,
    presenceMessageCodecType = 140,
    realtimePresenceParamsCodecType = 141,
    errorInfoCodecType = 142,
    connectionStateChangeCodecType = 143,
    channelStateChangeCodecType = 144,
};


@interface AblyPlatformMethod : NSObject
extern NSString *const AblyPlatformMethod_getPlatformVersion;
extern NSString *const AblyPlatformMethod_getVersion;
extern NSString *const AblyPlatformMethod_registerAbly;
extern NSString *const AblyPlatformMethod_authCallback;
extern NSString *const AblyPlatformMethod_realtimeAuthCallback;
extern NSString *const AblyPlatformMethod_createRestWithOptions;
extern NSString *const AblyPlatformMethod_publish;
extern NSString *const AblyPlatformMethod_restHistory;
extern NSString *const AblyPlatformMethod_restPresenceGet;
extern NSString *const AblyPlatformMethod_restPresenceHistory;
extern NSString *const AblyPlatformMethod_releaseRestChannel;
extern NSString *const AblyPlatformMethod_createRealtimeWithOptions;
extern NSString *const AblyPlatformMethod_connectRealtime;
extern NSString *const AblyPlatformMethod_closeRealtime;
extern NSString *const AblyPlatformMethod_attachRealtimeChannel;
extern NSString *const AblyPlatformMethod_detachRealtimeChannel;
extern NSString *const AblyPlatformMethod_setRealtimeChannelOptions;
extern NSString *const AblyPlatformMethod_realtimePresenceGet;
extern NSString *const AblyPlatformMethod_realtimePresenceHistory;
extern NSString *const AblyPlatformMethod_realtimePresenceEnter;
extern NSString *const AblyPlatformMethod_realtimePresenceUpdate;
extern NSString *const AblyPlatformMethod_realtimePresenceLeave;
extern NSString *const AblyPlatformMethod_onRealtimePresenceMessage;
extern NSString *const AblyPlatformMethod_publishRealtimeChannelMessage;
extern NSString *const AblyPlatformMethod_releaseRealtimeChannel;
extern NSString *const AblyPlatformMethod_realtimeHistory;
extern NSString *const AblyPlatformMethod_onRealtimeConnectionStateChanged;
extern NSString *const AblyPlatformMethod_onRealtimeChannelStateChanged;
extern NSString *const AblyPlatformMethod_onRealtimeChannelMessage;
extern NSString *const AblyPlatformMethod_nextPage;
extern NSString *const AblyPlatformMethod_firstPage;
@end

@interface TxTransportKeys : NSObject
extern NSString *const TxTransportKeys_channelName;
extern NSString *const TxTransportKeys_params;
extern NSString *const TxTransportKeys_data;
extern NSString *const TxTransportKeys_clientId;
extern NSString *const TxTransportKeys_options;
@end

@interface TxAblyMessage : NSObject
extern NSString *const TxAblyMessage_registrationHandle;
extern NSString *const TxAblyMessage_type;
extern NSString *const TxAblyMessage_message;
@end

@interface TxAblyEventMessage : NSObject
extern NSString *const TxAblyEventMessage_eventName;
extern NSString *const TxAblyEventMessage_type;
extern NSString *const TxAblyEventMessage_message;
@end

@interface TxErrorInfo : NSObject
extern NSString *const TxErrorInfo_code;
extern NSString *const TxErrorInfo_message;
extern NSString *const TxErrorInfo_statusCode;
extern NSString *const TxErrorInfo_href;
extern NSString *const TxErrorInfo_requestId;
extern NSString *const TxErrorInfo_cause;
@end

@interface TxMessageData : NSObject
extern NSString *const TxMessageData_data;
extern NSString *const TxMessageData_type;
@end

@interface TxClientOptions : NSObject
extern NSString *const TxClientOptions_authUrl;
extern NSString *const TxClientOptions_authMethod;
extern NSString *const TxClientOptions_key;
extern NSString *const TxClientOptions_tokenDetails;
extern NSString *const TxClientOptions_authHeaders;
extern NSString *const TxClientOptions_authParams;
extern NSString *const TxClientOptions_queryTime;
extern NSString *const TxClientOptions_useTokenAuth;
extern NSString *const TxClientOptions_hasAuthCallback;
extern NSString *const TxClientOptions_clientId;
extern NSString *const TxClientOptions_logLevel;
extern NSString *const TxClientOptions_tls;
extern NSString *const TxClientOptions_restHost;
extern NSString *const TxClientOptions_realtimeHost;
extern NSString *const TxClientOptions_port;
extern NSString *const TxClientOptions_tlsPort;
extern NSString *const TxClientOptions_autoConnect;
extern NSString *const TxClientOptions_useBinaryProtocol;
extern NSString *const TxClientOptions_queueMessages;
extern NSString *const TxClientOptions_echoMessages;
extern NSString *const TxClientOptions_recover;
extern NSString *const TxClientOptions_environment;
extern NSString *const TxClientOptions_idempotentRestPublishing;
extern NSString *const TxClientOptions_httpOpenTimeout;
extern NSString *const TxClientOptions_httpRequestTimeout;
extern NSString *const TxClientOptions_httpMaxRetryCount;
extern NSString *const TxClientOptions_realtimeRequestTimeout;
extern NSString *const TxClientOptions_fallbackHosts;
extern NSString *const TxClientOptions_fallbackHostsUseDefault;
extern NSString *const TxClientOptions_fallbackRetryTimeout;
extern NSString *const TxClientOptions_defaultTokenParams;
extern NSString *const TxClientOptions_channelRetryTimeout;
extern NSString *const TxClientOptions_transportParams;
@end

@interface TxTokenDetails : NSObject
extern NSString *const TxTokenDetails_token;
extern NSString *const TxTokenDetails_expires;
extern NSString *const TxTokenDetails_issued;
extern NSString *const TxTokenDetails_capability;
extern NSString *const TxTokenDetails_clientId;
@end

@interface TxTokenParams : NSObject
extern NSString *const TxTokenParams_capability;
extern NSString *const TxTokenParams_clientId;
extern NSString *const TxTokenParams_nonce;
extern NSString *const TxTokenParams_timestamp;
extern NSString *const TxTokenParams_ttl;
@end

@interface TxTokenRequest : NSObject
extern NSString *const TxTokenRequest_capability;
extern NSString *const TxTokenRequest_clientId;
extern NSString *const TxTokenRequest_keyName;
extern NSString *const TxTokenRequest_mac;
extern NSString *const TxTokenRequest_nonce;
extern NSString *const TxTokenRequest_timestamp;
extern NSString *const TxTokenRequest_ttl;
@end

@interface TxEnumConstants : NSObject
extern NSString *const TxEnumConstants_initialized;
extern NSString *const TxEnumConstants_connecting;
extern NSString *const TxEnumConstants_connected;
extern NSString *const TxEnumConstants_disconnected;
extern NSString *const TxEnumConstants_attaching;
extern NSString *const TxEnumConstants_attached;
extern NSString *const TxEnumConstants_detaching;
extern NSString *const TxEnumConstants_detached;
extern NSString *const TxEnumConstants_suspended;
extern NSString *const TxEnumConstants_closing;
extern NSString *const TxEnumConstants_closed;
extern NSString *const TxEnumConstants_failed;
extern NSString *const TxEnumConstants_absent;
extern NSString *const TxEnumConstants_leave;
extern NSString *const TxEnumConstants_enter;
extern NSString *const TxEnumConstants_present;
extern NSString *const TxEnumConstants_update;
@end

@interface TxConnectionStateChange : NSObject
extern NSString *const TxConnectionStateChange_current;
extern NSString *const TxConnectionStateChange_previous;
extern NSString *const TxConnectionStateChange_event;
extern NSString *const TxConnectionStateChange_retryIn;
extern NSString *const TxConnectionStateChange_reason;
@end

@interface TxChannelStateChange : NSObject
extern NSString *const TxChannelStateChange_current;
extern NSString *const TxChannelStateChange_previous;
extern NSString *const TxChannelStateChange_event;
extern NSString *const TxChannelStateChange_resumed;
extern NSString *const TxChannelStateChange_reason;
@end

@interface TxMessage : NSObject
extern NSString *const TxMessage_id;
extern NSString *const TxMessage_timestamp;
extern NSString *const TxMessage_clientId;
extern NSString *const TxMessage_connectionId;
extern NSString *const TxMessage_encoding;
extern NSString *const TxMessage_data;
extern NSString *const TxMessage_name;
extern NSString *const TxMessage_extras;
@end

@interface TxPresenceMessage : NSObject
extern NSString *const TxPresenceMessage_id;
extern NSString *const TxPresenceMessage_action;
extern NSString *const TxPresenceMessage_clientId;
extern NSString *const TxPresenceMessage_connectionId;
extern NSString *const TxPresenceMessage_data;
extern NSString *const TxPresenceMessage_encoding;
extern NSString *const TxPresenceMessage_extras;
extern NSString *const TxPresenceMessage_timestamp;
@end

@interface TxPaginatedResult : NSObject
extern NSString *const TxPaginatedResult_items;
extern NSString *const TxPaginatedResult_type;
extern NSString *const TxPaginatedResult_hasNext;
@end

@interface TxRestHistoryParams : NSObject
extern NSString *const TxRestHistoryParams_start;
extern NSString *const TxRestHistoryParams_end;
extern NSString *const TxRestHistoryParams_direction;
extern NSString *const TxRestHistoryParams_limit;
@end

@interface TxRealtimeHistoryParams : NSObject
extern NSString *const TxRealtimeHistoryParams_start;
extern NSString *const TxRealtimeHistoryParams_end;
extern NSString *const TxRealtimeHistoryParams_direction;
extern NSString *const TxRealtimeHistoryParams_limit;
extern NSString *const TxRealtimeHistoryParams_untilAttach;
@end

@interface TxRestPresenceParams : NSObject
extern NSString *const TxRestPresenceParams_limit;
extern NSString *const TxRestPresenceParams_clientId;
extern NSString *const TxRestPresenceParams_connectionId;
@end

@interface TxRealtimePresenceParams : NSObject
extern NSString *const TxRealtimePresenceParams_waitForSync;
extern NSString *const TxRealtimePresenceParams_clientId;
extern NSString *const TxRealtimePresenceParams_connectionId;
@end
