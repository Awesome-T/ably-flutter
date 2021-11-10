
import 'package:ably_flutter/ably_flutter.dart';

/// A named channel through with rest client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via realtime channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSL1
abstract class RestChannelInterface {
  /// creates a Rest channel instance
  RestChannelInterface(this.rest, this.push, this.name);

  /// reference to Rest client
  RestInterface rest;

  /// Channel to receive push notifications on
  PushChannel push;

  /// name of the channel
  String name;

  /// presence interface for this channel
  ///
  /// can only query presence on the channel and presence history
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL3
  RestPresenceInterface get presence;

  /// fetch message history on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2
  Future<PaginatedResultInterface<Message>> history([
    RestHistoryParams? params,
  ]);

  /// publish messages on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL1
  Future<void> publish({
    Message? message,
    List<Message>? messages,
    String? name,
    Object? data,
  });

  /// takes a ChannelOptions object and sets or updates the
  /// stored channel options, then indicates success
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL7
  Future<void> setOptions(RestChannelOptions options);
}
