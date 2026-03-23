import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_theme.dart';
import 'package:mail_previewer_web/features/archive/presentation/pages/archive_page.dart';
import 'package:mail_previewer_web/features/startup/presentation/widgets/startup_intro.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSG Archive for NİS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _StartupAppShell(),
    );
  }
}

class _StartupAppShell extends StatefulWidget {
  const _StartupAppShell();

  @override
  State<_StartupAppShell> createState() => _StartupAppShellState();
}

class _StartupAppShellState extends State<_StartupAppShell> {
  bool _showIntro = true;

  void _handleIntroFinished() {
    if (!mounted) {
      return;
    }

    setState(() {
      _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ArchivePage(),
        if (_showIntro)
          Positioned.fill(
            child: StartupIntro(onFinished: _handleIntroFinished),
          ),
      ],
    );
  }
}
