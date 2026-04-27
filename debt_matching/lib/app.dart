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
        title: 'Debt Matching',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true, brightness: Brightness.light),
        darkTheme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true, brightness: Brightness.dark),
        themeMode: themeProvider.mode,
        home: DashboardScreen(themeProvider: themeProvider),
      ),
    );
  }
}
