import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/presentation/dashboard/widgets/preview_panel.dart';

void main() {
  group('PreviewPanel', () {
    Widget buildPanel({Map<String, dynamic>? stats, int invalidCount = 0}) {
      return MaterialApp(home: Scaffold(body: PreviewPanel(
        stats: stats ?? {'total_records': 100, 'total_bonus': 5000000, 'bonus_1': 3000000,
          'bonus_2': 1500000, 'bonus_3': 500000, 'total_pushed': 10000000,
          'total_consumed': 8000000, 'total_remaining': 2000000},
        topResults: [{'customer': 'KH01', 'doc': 'CT001', 'bonus_1': 3000000, 'bonus_2': 0, 'bonus_3': 0}],
        invalidCount: invalidCount, onExport: () {}, onReset: () {},
      )));
    }

    testWidgets('shows summary cards with formatted numbers', (tester) async {
      await tester.pumpWidget(buildPanel());
      expect(find.text('5,000,000'), findsOneWidget); // total bonus
      expect(find.text('3,000,000'), findsWidgets); // bonus_1
    });

    testWidgets('shows warning when invalidCount > 0', (tester) async {
      await tester.pumpWidget(buildPanel(invalidCount: 5));
      expect(find.text('⚠️ Cảnh báo'), findsOneWidget);
    });

    testWidgets('no warning when invalidCount = 0 and reconciliation OK', (tester) async {
      await tester.pumpWidget(buildPanel());
      expect(find.text('⚠️ Cảnh báo'), findsNothing);
    });

    testWidgets('shows top results table', (tester) async {
      await tester.pumpWidget(buildPanel());
      expect(find.text('KH01'), findsOneWidget);
      expect(find.text('CT001'), findsOneWidget);
    });

    testWidgets('shows export and reset buttons', (tester) async {
      await tester.pumpWidget(buildPanel());
      expect(find.text('Xuất kết quả'), findsOneWidget);
      expect(find.text('Chọn file khác'), findsOneWidget);
    });

    testWidgets('shows compare button when onCompare provided', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: PreviewPanel(
        stats: {'total_records': 1, 'total_bonus': 0, 'bonus_1': 0, 'bonus_2': 0, 'bonus_3': 0,
          'total_pushed': 0, 'total_consumed': 0, 'total_remaining': 0},
        topResults: [], invalidCount: 0, onExport: () {}, onReset: () {}, onCompare: () {},
      ))));
      expect(find.text('So sánh'), findsOneWidget);
    });
  });
}
