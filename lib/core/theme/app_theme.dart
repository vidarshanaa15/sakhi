import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_spacing.dart';

class AppTheme {
  // Core palette
  static const Color primary = Color(0xFF3B1A32);       // deep plum/maroon
  static const Color primaryLight = Color(0xFF5C2E52);
  static const Color accent = Color(0xFFE8654A);         // coral (SOS, badges, active nav)
  static const Color background = Color(0xFFFBF5EE);     // warm cream
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1F1B1D);
  static const Color textSecondary = Color(0xFF7A7275);

  static const Color safetyGreen = Color(0xFF2E7D4F);
  static const Color safetyAmber = Color(0xFFF9A825);
  static const Color safetyRed = Color(0xFFC62828);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primary,
      scaffoldBackgroundColor: background,
    );

    final bodyText = GoogleFonts.interTextTheme(base.textTheme);
    final headingFont = GoogleFonts.playfairDisplayTextTheme(base.textTheme);

    // Merge: serif for large headline/title styles, sans-serif for everything else
    final textTheme = bodyText.copyWith(
      displayLarge: headingFont.displayLarge,
      displayMedium: headingFont.displayMedium,
      displaySmall: headingFont.displaySmall,
      headlineLarge: headingFont.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium: headingFont.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall: headingFont.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: headingFont.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: safetyRed,
      ),
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 2,
        indicatorColor: accent.withOpacity(0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? accent : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? accent : textSecondary);
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  static Color scoreColor(double score) {
    if (score >= 7.5) return safetyGreen;
    if (score >= 5.0) return safetyAmber;
    return safetyRed;
  }
}