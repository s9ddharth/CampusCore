import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class CampusCoreApp extends StatelessWidget {
  const CampusCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusCore',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      home: const _AppStartupPlaceholder(),
    );
  }
}

class _AppStartupPlaceholder extends StatelessWidget {
  const _AppStartupPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}