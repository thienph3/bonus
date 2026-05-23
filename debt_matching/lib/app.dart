import 'package:flutter/material.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/dashboard/dashboard_screen.dart';

class DebtMatchingApp extends StatefulWidget {
  const DebtMatchingApp({super.key});

  @override
  State<DebtMatchingApp> createState() => _DebtMatchingAppState();
}

class _DebtMatchingAppState extends State<DebtMatchingApp> {
  final themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) => MaterialApp(
        title: 'CKTT - Đối trừ công nợ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          brightness: Brightness.light,
          cardTheme: const CardThemeData(elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xFFE0E0E0)), borderRadius: BorderRadius.all(Radius.circular(8)))),
          dataTableTheme: const DataTableThemeData(dataRowMinHeight: 36, dataRowMaxHeight: 40, headingRowHeight: 36),
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 13)),
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          brightness: Brightness.dark,
          cardTheme: const CardThemeData(elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xFF424242)), borderRadius: BorderRadius.all(Radius.circular(8)))),
          dataTableTheme: const DataTableThemeData(dataRowMinHeight: 36, dataRowMaxHeight: 40, headingRowHeight: 36),
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 13)),
        ),
        themeMode: themeProvider.mode,
        home: DashboardScreen(themeProvider: themeProvider),
      ),
    );
  }
}
