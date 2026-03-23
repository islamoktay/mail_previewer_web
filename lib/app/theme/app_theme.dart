import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';
import 'package:mail_previewer_web/app/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Color(0xFFF7F7FF),
        secondary: AppColors.surfaceContainerHigh,
        onSecondary: AppColors.onSurface,
        error: Color(0xFF9F403D),
        onError: Color(0xFFFFF7F6),
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      textTheme: AppTextStyles.build(),
    );
  }
}
