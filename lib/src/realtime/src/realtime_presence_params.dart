import 'package:ably_flutter/ably_flutter.dart';

/// Params used as a filter for querying presence on a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTP11c
class RealtimePresenceParams {
  /// When true, [RealtimePresence.get] will wait until SYNC is complete
  /// before returning a list of members
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c1
  final bool waitForSync;

  /// filters members by the provided clientId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c2
  final String? clientId;

  /// filters members by the provided connectionId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c3
  final String? connectionId;

  /// initializes with [waitForSync] set to true by default
  RealtimePresenceParams({
    this.waitForSync = true,
    this.clientId,
    this.connectionId,
  });
}
