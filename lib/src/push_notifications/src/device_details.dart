import '../push_notifications.dart';
import 'device_push_details.dart';
import 'form_factor.dart';

/// Details of a registered device.
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCD1
abstract class DeviceDetails {
  /// The id of the device registration.
  ///
  /// Generated locally if not available
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD2
  String? id;

  /// populated for device registrations associated with a clientId (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD3
  String? clientId;

  /// The device platform.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD6
  DevicePlatform? platform;

  /// the device form factor.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD4
  FormFactor? formFactor;

  /// a map of string key/value pairs containing any other registered
  /// metadata associated with the device registration
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD5
  Map<String, String>? metadata;

  /// Device token. Generated locally, if not available.
  String? deviceSecret;

  /// Details of the push registration for this device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD7
  DevicePushDetails? push;
}
