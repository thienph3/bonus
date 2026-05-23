import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/presentation/dashboard/widgets/console_panel.dart';

void main() {
  group('ConsolePanel', () {
    testWidgets('shows log count in bar', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ConsolePanel(
        logs: ['Log 1', 'Log 2', 'Log 3'], scrollController: ScrollController(),
      ))));
      expect(find.text('Console (3)'), findsOneWidget);
    });

    testWidgets('shows last log in bar', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ConsolePanel(
        logs: ['First', 'Last message'], scrollController: ScrollController(),
      ))));
      expect(find.text('Last message'), findsOneWidget);
    });

    testWidgets('expands on tap', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ConsolePanel(
        logs: ['Log 1', 'Log 2'], scrollController: ScrollController(),
      ))));
      // Tap to expand
      await tester.tap(find.textContaining('Console'));
      await tester.pumpAndSettle();
      // After expand, logs visible in list
      expect(find.text('Log 2'), findsWidgets);
    });

    testWidgets('empty logs shows no last message', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: ConsolePanel(
        logs: [], scrollController: ScrollController(),
      ))));
      expect(find.text('Console (0)'), findsOneWidget);
    });
  });
}
