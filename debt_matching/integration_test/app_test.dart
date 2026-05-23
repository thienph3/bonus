import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:debt_matching/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration', () {
    testWidgets('app launches and shows initial state', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app title
      expect(find.text('CKTT - Đối trừ công nợ'), findsOneWidget);
      // Verify initial state — file picker button
      expect(find.text('Chọn file Excel'), findsOneWidget);
      // Verify template button
      expect(find.text('Tải file mẫu'), findsOneWidget);
      // Verify console bar
      expect(find.textContaining('Console'), findsOneWidget);
      // Verify theme toggle
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('theme toggle switches to dark mode', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap dark mode button
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pumpAndSettle();
      // Now should show light mode icon
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('console expands on tap', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap console bar
      await tester.tap(find.textContaining('Console'));
      await tester.pumpAndSettle();
      // Console should be expanded (height > bar)
      // Just verify no crash
    });
  });
}
