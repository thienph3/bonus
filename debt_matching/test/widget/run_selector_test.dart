import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/presentation/dashboard/widgets/run_selector.dart';
import 'package:debt_matching/data/database/app_database.dart';

RunHistory _run(String id, String status, {int records = 100}) => RunHistory(
  id: id, timestamp: DateTime(2024, 3, 15, 10, 30), filePath: 'test.xlsx',
  recordCount: records, levelCount: 2, holidayCount: 5, totalBonus: 1000000, status: status);

void main() {
  group('RunSelector', () {
    testWidgets('hidden when no runs', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RunSelector(
        runs: [], selectedRunId: null, onSelect: (_) {}, onDelete: (_) {},
      ))));
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('shows dropdown with runs', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RunSelector(
        runs: [_run('r1', 'completed'), _run('r2', 'imported')],
        selectedRunId: 'r1', onSelect: (_) {}, onDelete: (_) {},
      ))));
      expect(find.text('Kỳ: '), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('delete button shows confirm dialog', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RunSelector(
        runs: [_run('r1', 'completed')],
        selectedRunId: 'r1', onSelect: (_) {}, onDelete: (_) {},
      ))));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Xóa kỳ?'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Xóa'), findsOneWidget);
    });
  });
}
