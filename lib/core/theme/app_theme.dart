import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  const AppThemes._();

  static ThemeData get lightTheme => AppTheme.light();
  static ThemeData get darkTheme => AppTheme.dark();
  static ThemeData get medicalTheme => AppTheme.light();
  static ThemeData get journalTheme => AppTheme.journal();
}

class AppTheme {
  const AppTheme._();

  static const _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    },
  );

  static const darkBackground = Color(0xFF090D14);
  static const lightBackground = Color(0xFFF4F7FB);

  static const darkScheme = ColorScheme.dark(
    primary: Color(0xFF65E0C2),
    secondary: Color(0xFFFFC26F),
    tertiary: Color(0xFF7E9DFF),
    surface: Color(0xFF111927),
    error: Color(0xFFFF6D7A),
    onPrimary: Color(0xFF04110D),
    onSecondary: Color(0xFF1C1200),
    onSurface: Color(0xFFE8ECF5),
    onError: Color(0xFF2D0208),
  );

  static const lightScheme = ColorScheme.light(
    primary: Color(0xFF0FA58A),
    secondary: Color(0xFFE08A00),
    tertiary: Color(0xFF4A6CF7),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A2433),
    onError: Color(0xFFFFFFFF),
  );

  static ThemeData journal() {
    const paperBg = Color(0xFFF6F1E8);
    const cream = Color(0xFFFDFBF7);
    const ink = Color(0xFF1E2A38);
    const softGreen = Color(0xFFB7C97B);
    const softBrown = Color(0xFFAA8B6F);

    final scheme = ColorScheme.light(
      primary: ink,
      secondary: softGreen,
      tertiary: softBrown,
      surface: cream,
      error: const Color(0xFFB3261E),
      onPrimary: Colors.white,
      onSecondary: ink,
      onTertiary: Colors.white,
      onSurface: ink,
      onError: Colors.white,
    );

    // Handwritten-style text theme
    final baseText = ThemeData.light().textTheme;
    final textTheme = GoogleFonts.caveatTextTheme(baseText).copyWith(
      displayLarge: GoogleFonts.caveat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: ink,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.caveat(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: ink,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.caveat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.caveat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.caveat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.3,
      ),
      titleSmall: GoogleFonts.caveat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.indieFlower(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ink,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.indieFlower(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ink,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.indieFlower(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: ink,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.caveat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.caveat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: ink,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.caveat(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: ink,
        height: 1.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: paperBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: paperBg,
        elevation: 0,
        foregroundColor: ink,
        centerTitle: true,
        titleTextStyle: GoogleFonts.caveat(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: cream,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: ink.withValues(alpha: 0.2), width: 1.2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: 0.15),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        hintStyle: GoogleFonts.indieFlower(
          color: ink.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: GoogleFonts.caveat(
          color: ink.withValues(alpha: 0.72),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ink.withValues(alpha: 0.15), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ink.withValues(alpha: 0.15), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ink, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cream,
        selectedColor: softGreen.withValues(alpha: 0.2),
        disabledColor: ink.withValues(alpha: 0.05),
        side: BorderSide(color: ink.withValues(alpha: 0.2)),
        labelStyle: GoogleFonts.indieFlower(color: ink),
        secondaryLabelStyle: GoogleFonts.indieFlower(color: ink),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: cream,
          elevation: 2,
          textStyle: GoogleFonts.caveat(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: cream,
          textStyle: GoogleFonts.caveat(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: ink.withValues(alpha: 0.3)),
          textStyle: GoogleFonts.caveat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: softGreen,
        foregroundColor: ink,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink.withValues(alpha: 0.95),
        elevation: 2,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        contentTextStyle: GoogleFonts.indieFlower(color: cream),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cream,
        selectedItemColor: ink,
        unselectedItemColor: ink.withValues(alpha: 0.5),
        selectedLabelStyle: GoogleFonts.caveat(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.caveat(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
      ),
      pageTransitionsTheme: _pageTransitions,
    );
  }

  static const birthdayPrimary = Color(0xFFFF8A3D);
  static const birthdaySecondary = Color(0xFFFFC857);
  static const birthdayTertiary = Color(0xFFFF6FCF);

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      scheme: darkScheme,
      scaffoldBackground: darkBackground,
      baseTextTheme: ThemeData.dark().textTheme,
      inputFill: darkScheme.surface.withValues(alpha: 0.95),
      hintAlpha: 0.50,
      labelAlpha: 0.75,
      borderAlpha: 0.12,
      focusedBorderAlpha: 0.70,
      cardBorderAlpha: 0.10,
      chipBackground: darkScheme.surface.withValues(alpha: 0.90),
      chipSelectedAlpha: 0.20,
      chipDisabled: darkScheme.surface.withValues(alpha: 0.50),
      outlinedBorderAlpha: 0.20,
    );
  }

  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      scheme: lightScheme,
      scaffoldBackground: lightBackground,
      baseTextTheme: ThemeData.light().textTheme,
      inputFill: lightScheme.surface,
      hintAlpha: 0.45,
      labelAlpha: 0.72,
      borderAlpha: 0.15,
      focusedBorderAlpha: 0.80,
      cardBorderAlpha: 0.14,
      chipBackground: lightScheme.surface,
      chipSelectedAlpha: 0.16,
      chipDisabled: lightScheme.onSurface.withValues(alpha: 0.05),
      outlinedBorderAlpha: 0.24,
    );
  }

  static ThemeData birthday(BuildContext context) {
    final base = Theme.of(context);
    final birthdayScheme = base.colorScheme.copyWith(
      primary: birthdayPrimary,
      secondary: birthdaySecondary,
      tertiary: birthdayTertiary,
    );
    return base.copyWith(
      colorScheme: birthdayScheme,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: birthdayScheme.surface,
        foregroundColor: birthdayScheme.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: birthdayScheme.primary,
          foregroundColor: birthdayScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: birthdayScheme.primary,
      ),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required TextTheme baseTextTheme,
    required Color inputFill,
    required double hintAlpha,
    required double labelAlpha,
    required double borderAlpha,
    required double focusedBorderAlpha,
    required double cardBorderAlpha,
    required Color chipBackground,
    required double chipSelectedAlpha,
    required Color chipDisabled,
    required double outlinedBorderAlpha,
  }) {
    final baseText = GoogleFonts.plusJakartaSansTextTheme(
      baseTextTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final textTheme = GoogleFonts.spaceGroteskTextTheme(baseText).copyWith(
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.primary.withValues(alpha: cardBorderAlpha),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onSurface.withValues(alpha: 0.12),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        hintStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: hintAlpha),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: labelAlpha),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _inputBorder(scheme, borderAlpha),
        enabledBorder: _inputBorder(scheme, borderAlpha),
        focusedBorder: _inputBorder(scheme, focusedBorderAlpha, focused: true),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBackground,
        selectedColor: scheme.primary.withValues(alpha: chipSelectedAlpha),
        disabledColor: chipDisabled,
        side: BorderSide(color: scheme.onSurface.withValues(alpha: 0.15)),
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onSurface),
        brightness: brightness,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(
            color: scheme.onSurface.withValues(alpha: outlinedBorderAlpha),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surface,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        contentTextStyle: TextStyle(color: scheme.onSurface),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
      ),
      pageTransitionsTheme: _pageTransitions,
    );
  }

  static OutlineInputBorder _inputBorder(
    ColorScheme scheme,
    double alpha, {
    bool focused = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: (focused ? scheme.primary : scheme.onSurface).withValues(
          alpha: alpha,
        ),
      ),
    );
  }
}

extension AppThemeColors on ColorScheme {
  Color get cardSurface => surface.withValues(alpha: 0.74);
  Color get softSurface => surface.withValues(alpha: 0.72);
  Color get subtleBorder => onSurface.withValues(alpha: 0.13);
  Color get mutedText => onSurface.withValues(alpha: 0.68);
  Color get faintTrack => onSurface.withValues(alpha: 0.12);
  Color get chartAxis => onSurface.withValues(alpha: 0.24);
  Color get chartFill => primary.withValues(alpha: 0.14);
  Color get chartLine => primary;
  Color get chartPoint => secondary;
  List<Color> get barGradient => [
        primary.withValues(alpha: 0.85),
        tertiary.withValues(alpha: 0.75),
      ];
}
