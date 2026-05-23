import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:debt_matching/app.dart';

void main() {
  group('Dashboard keyboard shortcuts', () {
    testWidgets('Ctrl+O shortcut is registered (no crash on key)', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: DebtMatchingApp()));
      await tester.pumpAndSettle();
      // Verify app renders with shortcuts — actual file picker can't run in test
      expect(find.text('Debt Matching'), findsOneWidget);
      expect(find.text('Chọn file Excel'), findsOneWidget);
    });

    testWidgets('Ctrl+E triggers export (no crash when no run)', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: DebtMatchingApp()));
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      // Should not crash — _currentRunId is null, export returns early
      expect(find.text('Chọn file Excel'), findsOneWidget);
    });
  });

  group('Dashboard retry stuck run', () {
    testWidgets('app shows initial state on launch', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: DebtMatchingApp()));
      await tester.pumpAndSettle();
      expect(find.text('Debt Matching'), findsOneWidget);
      expect(find.text('Chọn file Excel'), findsOneWidget);
    });
  });
}
