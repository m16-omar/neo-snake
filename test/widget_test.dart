// This is a basic Flutter widget test for the Neon Snake game.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:snake/main.dart';

void main() {
  testWidgets('Neon Snake game splash and main flow test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that Splash Screen is visible.
    expect(find.text('NEON SNAKE'), findsOneWidget);
    expect(find.text('RETRO ARCADE'), findsOneWidget);

    // Wait for splash transition delay (2800ms) + fade transition (600ms)
    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pumpAndSettle(); // Wait for navigation transition to complete

    // Verify that score is initialized to 0 on the Game Screen.
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(
      find.text('0'),
      findsNWidgets(2),
    ); // score is 0, best score is 0 initially

    // Verify that start overlay is visible.
    expect(find.text('READY?'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
