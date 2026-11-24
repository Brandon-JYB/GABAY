import 'package:flutter/material.dart';

/// GABAY palette. Change a color here and the whole app follows.
class AppColors {
  AppColors._();

  static const phthalo = Color(0xFF19350C); // headings, primary actions
  static const mustard = Color(0xFF687D31); // accents, selected states
  static const lightGray = Color(0xFFD5D3CC); // borders, dividers
  static const deepSpace = Color(0xFF406768); // secondary surfaces
  static const moonstone = Color(0xFF6FA9BB); // highlights, info

  static const background = Color(0xFFF6F6F2); // light tint of Light Gray
  static const surface = Colors.white;
  static const textMuted = Color(0xFF5D6A58);
}

class AppAssets {
  AppAssets._();

  /// Put your GABAY logo here and list it under `flutter: assets:` in pubspec.yaml.
  static const logo = 'assets/images/gabay.png';
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.mustard).copyWith(
    primary: AppColors.phthalo,
    onPrimary: Colors.white,
    secondary: AppColors.deepSpace,
    onSecondary: Colors.white,
    tertiary: AppColors.moonstone,
    surface: AppColors.surface,
    onSurface: AppColors.phthalo,
    outlineVariant: AppColors.lightGray,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      height: 68,
      indicatorColor: AppColors.moonstone.withValues(alpha: 0.4),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.deepSpace : AppColors.textMuted,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.deepSpace : AppColors.textMuted,
        );
      }),
    ),
  );
}