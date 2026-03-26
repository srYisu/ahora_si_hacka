import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/dashboard_shell.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Precision Conservator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardShell(),
    );
  }
}
