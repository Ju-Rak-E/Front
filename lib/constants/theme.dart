import 'package:flutter/material.dart';

class AppTheme {
  // 앱의 주요 색상
  static const Color primaryColor = Color(0xFF4CAF50);  // 초록색
  static const Color secondaryColor = Color(0xFF2196F3);  // 파란색
  static const Color accentColor = Color(0xFFFFC107);  // 노란색
  static const Color errorColor = Color(0xFFE53935);  // 빨간색

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  // 배경 색상
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // 앱의 테마
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textLight,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
  );
} 