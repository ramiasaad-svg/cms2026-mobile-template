import 'package:flutter/material.dart';
import '../config/app_config.dart';

class AppTheme {
  final BrandingConfig branding;

  AppTheme(this.branding);

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: branding.primary,
    brightness: Brightness.light,
    fontFamily: branding.fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: branding.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: branding.accent),
    cardTheme: const CardThemeData(elevation: 1, margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: branding.primary,
    brightness: Brightness.dark,
    fontFamily: branding.fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: branding.secondary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  ThemeMode get themeMode => switch (branding.themeMode) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };
}
