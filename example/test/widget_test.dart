// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ably_flutter_example/main.dart';
import 'package:ably_flutter_example/ui/ably_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verify Platform version', (tester) async {
    // Build our app and trigger a frame.
    final ablyService = AblyService();
    await tester.pumpWidget(AblyFlutterExampleApp(ablyService));

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data!.startsWith('Running on:'),
      ),
      findsOneWidget,
    );
  });
}
