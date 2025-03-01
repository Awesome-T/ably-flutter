# Contributing to Ably Flutter

## Getting Started

The code in this repository has been constructed to be
[built as a Flutter Plugin](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin).
It is not yet constructed as a federated plugin but this is in our backlog as
[issue 118](https://github.com/ably/ably-flutter/issues/118).

After checking out this repository, run the following command:

    flutter pub get

You may also find it insightful to run the following command, as it can reveal issues with your development environment:

    flutter doctor

If using Android Studio, delete the `.packages` file. It is a deprecated autogenerated file which confuses Android Studio into thinking all files are build outputs instead of source files.

## Implementation Notes

### Hot reload, hot restart and app restart

There are 3 types of "refreshes" you might see in a Flutter app:
- **[Hot reload](https://docs.flutter.dev/development/tools/hot-reload):** Both Flutter and iOS apps are **not** restarted. The application state remains the same. Updated source files are injected into the running Dart VM.
- **Hot restart:** The Flutter application is restarted, but the host application (Android and iOS apps which host the Flutter application) does not.
  - State of the flutter application is reset. This means fields are all reset to their default values (or null).
  - This also means we must remember to clear the state in the host application when the app hot restarts. We do this by calling `await methodChannel.invokeMethod(PlatformMethod.resetAblyClients);`.
  - From Flutter documentation:
> With a hot restart, the program starts from the beginning, executes the new version of main(), and builds a widget tree that displays the text Hello.
- **App restart:** The entire application is restarted, clearing the state of both the Flutter application and the host application (Android and iOS apps).

### Exceptions and Errors

Dart libraries don't _extend_ the [Exception class](https://api.dart.dev/stable/2.4.0/dart-core/Exception-class.html),
they _implement_ its implicit interface.
(see [this comment](https://stackoverflow.com/questions/13579982/custom-exceptions-in-dart#comment18616624_13580222)).

For the moment it would not seem appropriate for our plugin to throw instances conforming to the implicit interface
of the [Error class](https://api.dart.dev/stable/2.4.0/dart-core/Error-class.html), as this is perhaps more
appropriate for programmer's failures on the Dart side of things. But time will tell.

### Push Notifications 

#### Push Notifications activation and deactivation

The platform SDKs ([ably-android](https://github.com/ably/ably-java) and [ably-cocoa](https://github.com/ably/ably-cocoa)) enable users to check if device activation, deactivation, or registration update fails. On Android, these errors are sent in Intents which users should register for at runtime. In Cocoa, errors are returned through `ARTPushRegistererDelegate` methods. However, in both SDKs, this error does not always return quickly. For example, if there was no internet connection, then `Push.activate()` will not throw an error, it will just block forever, because errors are not provided by the SDKs. Once an internet connection is made, the Intent will be sent and delegate methods will be called.

Ably Flutter does this by passing a reference to the `FlutterResult` used to pass back the result to the Dart side, when the activation or deactivation completes. This makes it convenient for users: they can `await push.activate()`. However, users should not rely on this Future completing, in the case of network issues.

#### Notification tap handling

Android's Firebase Messaging library enables users to select the Intent action used when the automatically-generated notification is tapped by the user. Users can do this by setting `fcm.notification.click_action` in Ably's push payload. However, for this to work, users would need to declare the intent action within their `AndroidManifest.xml`. Therefore, we don't really tell users they can modify `click_action` and configure it. However, they can do so if they wish.

#### Notifications generation for Foreground Apps

iOS enables users to show the notification received remotely even if the app is in the foreground, by calling a delegate method ([`userNotificationCenter(_:willPresent:withCompletionHandler:)`](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/1649518-usernotificationcenter)) which the user can choose to show the message to the user, based on the notification content. FCM does not provide this functionality. Users can only configure this behaviour for iOS, by using `PushNotificationEvents#setOnShowNotificationInForeground`. 

#### Push Notifications Background Message Handling

Background processing in Flutter is a complicated subject that has not been explored publicly in detail. It involves creating Dart isolates manually (for Android), passing messages back and forth, etc.

Differences between Ably Flutter and Firebase Messaging implementation (Android only):
- **Isolate code:** Firebase Messaging explicitly defines a callback which is launched in a custom isolate. Ably Flutter does not launch a custom dart entrypoint, but instead re-uses the user's default entrypoint (their Flutter application), by using `DartExecutor.DartEntrypoint.createDefault()`. Therefore, Ably Flutter provides the same environment for message handling on both Android and iOS: users application **is running** when we handle the message.
- **Resource consumption tradeoffs:** Firebase launches an isolate capable of only handling messages at app launch, even if users' application isn't handling remote messages. Firebase Messaging keeps this isolate running throughout the app, and have a queue process to queue messages by maintaining an Android Service. This allows 10 minutes of execution time, where as on iOS, Firebase Messaging only has 30 seconds of execution time. Instead, Ably Flutter launches a new isolate on every message if the application is not yet running and avoids creating a service and queueing work. A new message will spawn a new engine.
- **Execution time:** Ably Flutter provides users with an execution time of 30 seconds on both Android and iOS to handle each message. On Android, Firebase messaging launches a Service which has [approximately 10 minutes](https://stackoverflow.com/questions/48630606/how-long-is-the-jobservice-execution-time-limit-mentioned-in-androids-jobinte) of execution time from it's launch to handle all messages received before Android stops the service. It's unclear if the Service will be automatically launched by iOS immediately, or if it will only be launched in the future. On iOS, each message has 30 seconds of execution time. This seems to be a bug in the design of firebase_messaging. Users can extend their execution time by using [package:workmanager](https://pub.dev/packages/workmanager).
  
Because of this architectural simplicity, Ably Flutter does not need to use [`PluginUtilities`](https://stackoverflow.com/questions/69208164/what-does-pluginutilities-do-in-flutters-dartui-library-and-how-do-i-use/69208165#69208165), pass references of two methods between Dart and host platform, or save and load these methods in `SharedPreferences`. Ably Flutter avoids conflicts between the default `FlutterEngine` launched with a `FlutterActivity` and the one manually launched in the `BroadcastReceiver`, by using method channels with unique channel names.

## Platform Notes

### Android

The Android project does use [AndroidX](https://developer.android.com/jetpack/androidx), which appears to be the default specified when Flutter created the plugin project, however Flutter's Java API for plugins (e.g. [MethodChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/MethodChannel.html)) appears to still use deprecated platform APIs like the [UiThread](https://developer.android.com/reference/android/support/annotation/UiThread) annotation.

### iOS

Once changes have been made to the platform code in the [ios folder](ios), especially if those changes involve changing
[the pod spec](ios/ably_flutter.podspec) to add a dependency, then it may be necessary to force that build up stream with:

1. Bump `s.version` in the pod spec
2. From [example/ios](example/ios) run `pod install`
3. Open [Runner.xcworkspace](example/ios/Runner.xcworkspace) in Xcode, clean and build

Otherwise, after making simple code changes to the platform code it will not get seen with a hot restart "R".
Therefore if there's a current emulation running then use "q" to quit it and then re-run the emulator - e.g. with this if you've
got both iOS and Android emulators open:

    flutter run -d all

## Debugging notes (Android Studio)

To debug both platform and Dart code simultaneously:
- In Android: in the Flutter project window, launch the application in debug mode in Android Studio. Then, in the Android project window, attach the debugger to the Android process.
- In iOS: To debug iOS code, you must set breakpoints in Xcode. In Android Studio or command line, run the flutter run --dart-define` command you would usually run. This ensures when you build with Xcode, the environment variables are available to the app. Then, re-run the application using Xcode. Then, in Android Studio, click `Run` > `Flutter Attach`, or click the `Flutter Attach` button.

## Testing changes in dependencies

After making changes to `ably-java` or `ably-cocoa`, you can test changes without releasing those dependencies to users. To do this, you need a local copy of the repo with the changes you want to test.

To test `ably-cocoa` changes, in `Podfile`, below `target 'Runner' do`, add:

```ruby
    pod 'Ably', :path => 'local/path/to/ably-cocoa'
```

To test `ably-java` changes, see [Using ably-java / ably-android locally in other projects](https://github.com/ably/ably-java/blob/main/CONTRIBUTING.md#using-ably-java--ably-android-locally-in-other-projects).

## Writing documentation

As features are developed, ensure documentation (both in the public API interface) and in relevant markdown files are updated. When referencing images in markdown files, using a local path such as `images/android.png`, for example `![An android device running on API level 30](images/android.png)` will result in the image missing on pub.dev README preview. Therefore, we currently reference images through the github.com URL path (`https://github.com/ably/ably-flutter/raw/`), for example to reference `images/android.png`, we would use `![An android device running on API level 30](https://github.com/ably/ably-flutter/raw/main/images/android.png)`. [A suggestion](https://github.com/dart-lang/pub-dev/issues/5068) has been made to automatically replace this relative image path to the github URL path.

## Helpful Resources

- Flutter
[plug-in package development](https://flutter.dev/developing-packages/),
being a specialized package that includes platform-specific implementation code for Android and/or iOS.
- Flutter
[documentation](https://flutter.dev/docs), offering tutorials, 
samples, guidance on mobile development, and a full API reference.


## Generating platform constants

Some files in the project are generated to maintain sync between
 platform constants on both native and dart side.
  Generated file paths are configured as values in `bin/codegen.dart` for `toGenerate` Map

[Read about generation of platform specific constant files](bin/README.md)

## Implementing new codec types

1. Add new type along with value in `_types` list at [bin/codegen_context.dart](bin/codegen_context.dart)
2. Add an object definition  with object name and its properties to `objects` list at [bin/codegen_context.dart](bin/codegen_context.dart)
 This will create `Tx<ObjectName>` under which all properties are accessible.
 
Generate platform constants and continue

3. update `getCodecType` in [Codec.dart](lib/src/platform/src/codec.dart) so new codec type is returned based on runtime type
4. update `codecPair` in [Codec.dart](lib/src/platform/src/codec.dart)  so new encoder/decoder is assigned for new type
5. update `writeValue` in [android.src.main.java.io.ably.flutter.plugin.AblyMessageCodec](android/src/main/java/io/ably/flutter/plugin/AblyMessageCodec.java)
 so new codec type is obtained from runtime type
6. update `codecMap` in [android.src.main.java.io.ably.flutter.plugin.AblyMessageCodec](android/src/main/java/io/ably/flutter/plugin/AblyMessageCodec.java)
 so new encoder/decoder is assigned for new type
7. add new codec encoder method in [ios.Classes.codec.AblyFlutterWriter](ios/Classes/codec/AblyFlutterWriter.m)
 and update `getType` and `getEncoder` so that new codec encoder is called
8. add new codec encoder method in [ios.classes.codec.AblyFlutterReader](ios/Classes/codec/AblyFlutterReader.m)
 and update `getDecoder` so that new codec decoder is called

## Implementing new platform methods

1. Add new method name in `_platformMethods` list at [bin/codegen_context.dart](bin/codegen_context.dart)

Generate platform constants and use wherever required

## Static plugin code analyzer

The new flutter analyzer does a great job at analyzing complete flutter package.

Running `flutter analyze` in project root will analyze dart files in complete project,
 i.e., plugin code and example code


Or, use the good old dart analyzer

```bash
dartanalyzer --fatal-warnings lib/**/*.dart

dartanalyzer --fatal-warnings example/lib/**/*.dart
```

## dartdoc

### Tool Installation

With just the Flutter tools installed, the following is observed:

```
ably-flutter % which dartdoc
dartdoc not found

?1 ably-flutter % which flutter
/Users/quintinwillison/flutter/bin/flutter
```

The `dartdoc` tool can be activated via the `flutter` command like this:

```
ably-flutter % flutter pub global activate dartdoc
Resolving dependencies...
Downloading...
Precompiling executables...
Precompiled dartdoc:dartdoc.
Installed executable dartdoc.
Warning: Pub installs executables into $HOME/flutter/.pub-cache/bin, which is not on your path.
You can fix that by adding this to your shell's config file (.bashrc, .bash_profile, etc.):

  export PATH="$PATH":"$HOME/flutter/.pub-cache/bin"

Activated dartdoc 0.39.0.
```

And, indeed, on inspecting my path I could confirm that it wasn't present:

```
ably-flutter % echo $PATH
/Users/quintinwillison/.asdf/shims:/Users/quintinwillison/.asdf/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/MacGPG2/bin:/usr/local/share/dotnet:~/.dotnet/tools:/Library/Apple/usr/bin:/Users/quintinwillison/Library/Android/sdk/platform-tools:/Users/quintinwillison/flutter/bin
```

So I edited my configuration to add the `PATH` export suggested:

```
ably-flutter % vi ~/.zshrc
ably-flutter % source ~/.zshrc
ably-flutter % echo $PATH
/Users/quintinwillison/.asdf/shims:/Users/quintinwillison/.asdf/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/MacGPG2/bin:/usr/local/share/dotnet:~/.dotnet/tools:/Library/Apple/usr/bin:/Users/quintinwillison/Library/Android/sdk/platform-tools:/Users/quintinwillison/flutter/bin:/Users/quintinwillison/Library/Android/sdk/platform-tools:/Users/quintinwillison/flutter/bin:/Users/quintinwillison/flutter/.pub-cache/bin
```

And I was then able to find the `dartdoc` tool:

```
ably-flutter % which dartdoc
/Users/quintinwillison/flutter/.pub-cache/bin/dartdoc
```

And see that it had been installed globally in the Flutter context:

```
ably-flutter % flutter pub global list
dartdoc 0.39.0
```

### Generating Documentation

```
ably-flutter % dartdoc
Documenting ably_flutter...
Initialized dartdoc with 195 libraries in 180.4 seconds
Generating docs for library ably_flutter from package:ably_flutter/ably_flutter.dart...
Validating docs...
  warning: dartdoc generated a broken link to: DeveloperNotes.md, linked to from package-ably_flutter: file:///Users/quintinwillison/code/ably/ably-flutter
found 1 warning and 0 errors
Documented 1 public library in 5.6 seconds
Success! Docs generated into /Users/quintinwillison/code/ably/ably-flutter/doc/api
```

## Release Process

Releases should always be made through a release pull request (PR), which needs to bump the version number and add to the [change log](CHANGELOG.md).
For an example of a previous release PR, see [#89](https://github.com/ably/ably-flutter/pull/89).

The release process must include the following steps:

1. Ensure that all work intended for this release has landed to `main`
2. Create a release branch named like `release/1.2.3`
3. Add a commit to bump the version number
   - Update the version in `pubspec.yaml`
   - Update the version of ably-flutter used in the example app and test integration app `podfile.lock` files:
   - Run `pod install` in `example/ios` and `test_integration/ios`, or run `pod install --project-directory=example/ios` and `pod install --project-directory=test_integration/ios`
   - Commit this
4. Add a commit to update the change log. 
  - Autogenerate the changelog contents by running `github_changelog_generator -u ably -p ably-flutter --since-tag v1.2.2 --output delta.md` and manually copying the relevant contents from `delta.md` into `CHANGELOG.md`
  - Make sure to replace `HEAD` in the autogenerated URL's with the version tag you will create (e.g. `v1.2.3`).
5. Check that everything is looking sensible to the Flutter tools without publishing by running: `flutter pub publish --dry-run`
6. Push the release branch to GitHub
7. Open a PR for the release against the release branch you just pushed
8. Gain approval(s) for the release PR from maintainer(s)
9. Land the release PR to `main`
10. Execute `flutter pub publish` from the root of this repository
11. Create a tag named like `v1.2.3`, using `git tag v1.2.3`
12. Push the newly created tag to GitHub: `git push origin v1.2.3`
13. Create a release on GitHub following the [previous releases]((https://github.com/ably/ably-flutter/releases)) as examples.

We tend to use [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator) to collate the information required for a change log update.
Your mileage may vary, but it seems the most reliable method to invoke the generator is something like:
`github_changelog_generator -u ably -p ably-flutter --since-tag v1.2.0 --output delta.md`
and then manually merge the delta contents in to the main change log (where `v1.2.0` in this case is the tag for the previous release).
