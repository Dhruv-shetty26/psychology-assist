import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Comprehensive theme data for light, dark, and medical themes
class AppThemes {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      tertiary: AppColors.lightAccent,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: AppColors.lightBg,
      onSecondary: Colors.white,
      onSurface: AppColors.lightText,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headingMedium.copyWith(
        color: AppColors.lightText,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightText),
    ),
    cardTheme: CardTheme(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(color: AppColors.lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightDivider,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.lightSubtext,
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.lightText,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.lightText,
      ),
      headlineSmall: AppTypography.headingSmall.copyWith(
        color: AppColors.lightText,
      ),
      titleLarge: AppTypography.headingLarge.copyWith(
        color: AppColors.lightText,
      ),
      titleMedium: AppTypography.headingMedium.copyWith(
        color: AppColors.lightText,
      ),
      titleSmall: AppTypography.headingSmall.copyWith(
        color: AppColors.lightText,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightText),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.lightText),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: AppColors.lightSubtext,
      ),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.lightText),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.lightSubtext,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 0.5,
      space: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    extensions: <ThemeExtension<dynamic>>[_CustomThemeExtension.light()],
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkAccent,
      surface: AppColors.darkSurface,
      background: AppColors.darkBg,
      error: AppColors.error,
      onPrimary: AppColors.darkBg,
      onSecondary: AppColors.darkBg,
      onSurface: AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headingMedium.copyWith(
        color: AppColors.darkText,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBg,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(color: AppColors.darkBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkDivider,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.darkSubtext,
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.darkText,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.darkText,
      ),
      headlineSmall: AppTypography.headingSmall.copyWith(
        color: AppColors.darkText,
      ),
      titleLarge: AppTypography.headingLarge.copyWith(
        color: AppColors.darkText,
      ),
      titleMedium: AppTypography.headingMedium.copyWith(
        color: AppColors.darkText,
      ),
      titleSmall: AppTypography.headingSmall.copyWith(
        color: AppColors.darkText,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkText),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkText),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkSubtext),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkText),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.darkSubtext,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 0.5,
      space: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkBg,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    extensions: <ThemeExtension<dynamic>>[_CustomThemeExtension.dark()],
  );

  // Medical Theme (clean, clinical, healthcare-focused)
  static ThemeData medicalTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.medicalPrimary,
      secondary: AppColors.medicalSecondary,
      tertiary: AppColors.medicalAccent,
      surface: AppColors.medicalSurface,
      background: AppColors.medicalBg,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.medicalText,
    ),
    scaffoldBackgroundColor: AppColors.medicalBg,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.medicalSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headingMedium.copyWith(
        color: AppColors.medicalText,
      ),
      iconTheme: const IconThemeData(color: AppColors.medicalText),
    ),
    cardTheme: CardTheme(
      color: AppColors.medicalSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.medicalBorder, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.medicalPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.medicalPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.medicalPrimary,
        side: const BorderSide(color: AppColors.medicalBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.medicalDivider,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.medicalBorder,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.medicalPrimary, width: 2),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.medicalSubtext,
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.medicalText,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.medicalText,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.medicalText,
      ),
      headlineSmall: AppTypography.headingSmall.copyWith(
        color: AppColors.medicalText,
      ),
      titleLarge: AppTypography.headingLarge.copyWith(
        color: AppColors.medicalText,
      ),
      titleMedium: AppTypography.headingMedium.copyWith(
        color: AppColors.medicalText,
      ),
      titleSmall: AppTypography.headingSmall.copyWith(
        color: AppColors.medicalText,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.medicalText),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.medicalText,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: AppColors.medicalSubtext,
      ),
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.medicalText,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.medicalSubtext,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.medicalBorder,
      thickness: 0.5,
      space: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.medicalPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    extensions: <ThemeExtension<dynamic>>[_CustomThemeExtension.medical()],
  );
}

/// Custom theme extension for additional theme properties
class _CustomThemeExtension extends ThemeExtension<_CustomThemeExtension> {
  final Color cardBorder;
  final Color shadowColor;
  final double cardRadius;

  _CustomThemeExtension({
    required this.cardBorder,
    required this.shadowColor,
    required this.cardRadius,
  });

  factory _CustomThemeExtension.light() => _CustomThemeExtension(
        cardBorder: AppColors.lightBorder,
        shadowColor: const Color(0x1A000000),
        cardRadius: 16,
      );

  factory _CustomThemeExtension.dark() => _CustomThemeExtension(
        cardBorder: AppColors.darkBorder,
        shadowColor: const Color(0x4D000000),
        cardRadius: 16,
      );

  factory _CustomThemeExtension.medical() => _CustomThemeExtension(
        cardBorder: AppColors.medicalBorder,
        shadowColor: const Color(0x1A000000),
        cardRadius: 16,
      );

  @override
  ThemeExtension<_CustomThemeExtension> copyWith({
    Color? cardBorder,
    Color? shadowColor,
    double? cardRadius,
  }) {
    return _CustomThemeExtension(
      cardBorder: cardBorder ?? this.cardBorder,
      shadowColor: shadowColor ?? this.shadowColor,
      cardRadius: cardRadius ?? this.cardRadius,
    );
  }

  @override
  ThemeExtension<_CustomThemeExtension> lerp(
    ThemeExtension<_CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! _CustomThemeExtension) {
      return this;
    }
    return _CustomThemeExtension(
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
    );
  }
}
