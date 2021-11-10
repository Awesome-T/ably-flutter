import 'package:ably_flutter/ably_flutter.dart';

/// This file contains push notification types specific to iOS. All types begin
/// with "UN", since these types belong to the User Notifications framework
///
/// These types exist so we can use iOS specific notification APIs, such as
/// getting the current notification settings/ permissions the application has,
/// and requesting permissions.

/// UNAuthorizationStatus: Constants indicating whether the app is allowed to
/// schedule notifications.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus)
enum UNAuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
  ephemeral
}

/// Constants indicating the presentation styles for alerts.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unalertstyle)
enum UNAlertStyle { none, banner, alert }

/// Constants that indicate the current status of a notification setting.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unnotificationsetting)
enum UNNotificationSetting { notSupported, disabled, enabled }

/// Constants indicating the style previewing a notification's content.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unshowpreviewssetting)
enum UNShowPreviewsSetting { always, whenAuthenticated, never }

/// The object for managing notification-related settings and the authorization
/// status of your app.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unnotificationsettings)
class UNNotificationSettings {
  UNAuthorizationStatus authorizationStatus;
  UNNotificationSetting soundSetting;
  UNNotificationSetting badgeSetting;
  UNNotificationSetting alertSetting;
  UNNotificationSetting notificationCenterSetting;
  UNNotificationSetting lockScreenSetting;
  UNNotificationSetting carPlaySetting;
  UNAlertStyle alertStyle;
  UNShowPreviewsSetting showPreviewsSetting;
  UNNotificationSetting criticalAlertSetting;
  bool providesAppNotificationSettings;
  UNNotificationSetting announcementSetting;

  /// Users do not create this class. Call [Push.getNotificationSettings]
  /// instead.
  UNNotificationSettings(
      {required this.authorizationStatus,
      required this.soundSetting,
      required this.badgeSetting,
      required this.alertSetting,
      required this.notificationCenterSetting,
      required this.lockScreenSetting,
      required this.carPlaySetting,
      required this.alertStyle,
      required this.showPreviewsSetting,
      required this.criticalAlertSetting,
      required this.providesAppNotificationSettings,
      required this.announcementSetting});
}
