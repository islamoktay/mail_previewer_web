import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_theme.dart';
import 'package:mail_previewer_web/features/archive/presentation/pages/archive_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSG Archive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ArchivePage(),
    );
  }
}
