import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debt_matching/presentation/dashboard/dashboard_state_views.dart';

void main() {
  group('Dashboard State Views', () {
    testWidgets('initial view shows file picker button', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(
        body: Builder(builder: (ctx) => buildInitialView(ctx, () {})),
      )));
      expect(find.text('Chọn file Excel'), findsOneWidget);
    });

    testWidgets('initial view shows template button when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(
        body: Builder(builder: (ctx) => buildInitialView(ctx, () {}, onDownloadTemplate: () {})),
      )));
      expect(find.text('Tải file mẫu'), findsOneWidget);
    });

    testWidgets('processing view shows progress', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: buildProcessingView(2))));
      expect(find.text('Bước 2/4: Sắp xếp'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('processing view step 0 shows generic message', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: buildProcessingView(0))));
      expect(find.text('Đang xử lý...'), findsOneWidget);
    });

    testWidgets('exported view shows success', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(
        body: buildExportedView('/path/to/file.xlsx', () {}),
      )));
      expect(find.text('Xuất file thành công!'), findsOneWidget);
      expect(find.text('/path/to/file.xlsx'), findsOneWidget);
    });

    testWidgets('error view shows message and retry', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(
        body: buildErrorView('Something went wrong', () {}),
      )));
      expect(find.textContaining('Something went wrong'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });
}
