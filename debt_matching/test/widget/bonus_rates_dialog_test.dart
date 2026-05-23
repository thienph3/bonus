import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/presentation/dashboard/widgets/bonus_rates_dialog.dart';

void main() {
  group('BonusRatesDialog', () {
    testWidgets('shows 3 tier input fields', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (ctx) =>
        ElevatedButton(onPressed: () => showBonusRatesDialog(ctx), child: const Text('Open')))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Tier 1 (%)'), findsOneWidget);
      expect(find.text('Tier 2 (%)'), findsOneWidget);
      expect(find.text('Tier 3 (%)'), findsOneWidget);
    });

    testWidgets('has cancel, skip, and apply buttons', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (ctx) =>
        ElevatedButton(onPressed: () => showBonusRatesDialog(ctx), child: const Text('Open')))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Bỏ qua'), findsOneWidget);
      expect(find.text('Áp dụng'), findsOneWidget);
    });

    testWidgets('skip returns empty map', (tester) async {
      Map<String, double>? result;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (ctx) =>
        ElevatedButton(onPressed: () async { result = await showBonusRatesDialog(ctx); },
          child: const Text('Open')))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bỏ qua'));
      await tester.pumpAndSettle();
      expect(result, isEmpty);
    });

    testWidgets('cancel returns null', (tester) async {
      Map<String, double>? result = {};
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (ctx) =>
        ElevatedButton(onPressed: () async { result = await showBonusRatesDialog(ctx); },
          child: const Text('Open')))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });
}
