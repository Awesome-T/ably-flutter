/// spec: https://docs.ably.com/client-lib-development-guide/features/#TE1
class TokenRequest {
  /// [keyName] is the first part of Ably API Key.
  ///
  /// provided keyName will be used to authorize requests made to Ably.
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE2
  ///
  /// More details about Ably API Key:
  /// https://docs.ably.com/client-lib-development-guide/features/#RSA11
  String? keyName;

  /// An opaque nonce string of at least 16 characters to ensure
  ///	uniqueness of this request. Any subsequent request using the
  ///	same nonce will be rejected.
  ///
  /// spec:
  /// https://docs.ably.com/client-lib-development-guide/features/#TE2
  /// https://docs.ably.com/client-lib-development-guide/features/#TE5
  String? nonce;

  /// The "Message Authentication Code" for this request.
  ///
  /// See the Ably Authentication documentation for more details.
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE2
  String? mac;

  /// stringified capabilities JSON
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TE3
  String? capability;

  ///  Client ID assigned to the tokenRequest.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TE2
  String? clientId;

  /// timestamp long – The timestamp (in milliseconds since the epoch)
  /// of this request. Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE5
  DateTime? timestamp;

  /// ttl attribute represents time to live (expiry)
  /// of this token in milliseconds
  ///
  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE4
  int? ttl;

  /// instantiates a [TokenRequest] with provided values
  TokenRequest({
    this.keyName,
    this.nonce,
    this.clientId,
    this.mac,
    this.capability,
    this.timestamp,
    this.ttl,
  });

  /// spec: https://docs.ably.com/client-lib-development-guide/features/#TE7
  TokenRequest.fromMap(Map<String, dynamic> map) {
    keyName = map['keyName'] as String?;
    nonce = map['nonce'] as String?;
    mac = map['mac'] as String?;
    capability = map['capability'] as String?;
    clientId = map['clientId'] as String?;
    timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int);
    final ttl = map['ttl'] as int?;
    if (ttl != null) this.ttl = ttl;
  }
}
