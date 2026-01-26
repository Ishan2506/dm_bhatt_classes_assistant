import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dm_bhatt_classes_new/utils/app_sizes.dart';

// --- Text Theme ---
TextTheme createTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.roboto(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium: GoogleFonts.roboto(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0),
    displaySmall: GoogleFonts.roboto(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0),
    headlineLarge: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0),
    headlineMedium: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0),
    headlineSmall: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0),
    titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0),
    titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
    titleSmall: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1),
    labelMedium: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
}

// --- Widget Themes ---
class CustomInputDecorationTheme {
  static InputDecorationThemeData getTheme(ColorScheme colorScheme) {
    return InputDecorationThemeData(
      contentPadding: P.all16,
      prefixIconColor: colorScheme.primary,
      suffixIconColor: colorScheme.onSurfaceVariant,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.s12),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.s12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.s12),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.s12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }
}

// --- App Theme ---
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff445e91),
      surfaceTint: Color(0xff445e91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd8e2ff),
      onPrimaryContainer: Color(0xff2b4678),
      secondary: Color(0xff226a4c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffaaf2cc),
      onSecondaryContainer: Color(0xff005236),
      tertiary: Color(0xff256489),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc9e6ff),
      onTertiaryContainer: Color(0xff004c6e),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff7f9fe),
      onSurface: Color(0xff181c20),
      onSurfaceVariant: Color(0xff43474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xffadc6ff),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff001a42),
      primaryFixedDim: Color(0xffadc6ff),
      onPrimaryFixedVariant: Color(0xff2b4678),
      secondaryFixed: Color(0xffaaf2cc),
      onSecondaryFixed: Color(0xff002113),
      secondaryFixedDim: Color(0xff8ed5b0),
      onSecondaryFixedVariant: Color(0xff005236),
      tertiaryFixed: Color(0xffc9e6ff),
      onTertiaryFixed: Color(0xff001e2f),
      tertiaryFixedDim: Color(0xff94cdf7),
      onTertiaryFixedVariant: Color(0xff004c6e),
      surfaceDim: Color(0xffd7dadf),
      surfaceBright: Color(0xfff7f9fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f4f9),
      surfaceContainer: Color(0xffebeef3),
      surfaceContainerHigh: Color(0xffe5e8ed),
      surfaceContainerHighest: Color(0xffe0e3e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffadc6ff),
      surfaceTint: Color(0xffadc6ff),
      onPrimary: Color(0xff112f60),
      primaryContainer: Color(0xff2b4678),
      onPrimaryContainer: Color(0xffd8e2ff),
      secondary: Color(0xff8ed5b0),
      onSecondary: Color(0xff003824),
      secondaryContainer: Color(0xff005236),
      onSecondaryContainer: Color(0xffaaf2cc),
      tertiary: Color(0xff94cdf7),
      onTertiary: Color(0xff00344d),
      tertiaryContainer: Color(0xff004c6e),
      onTertiaryContainer: Color(0xffc9e6ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff101417),
      onSurface: Color(0xffe0e3e8),
      onSurfaceVariant: Color(0xffc4c6cf),
      outline: Color(0xff8e9199),
      outlineVariant: Color(0xff43474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e3e8),
      inversePrimary: Color(0xff445e91),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff001a42),
      primaryFixedDim: Color(0xffadc6ff),
      onPrimaryFixedVariant: Color(0xff2b4678),
      secondaryFixed: Color(0xffaaf2cc),
      onSecondaryFixed: Color(0xff002113),
      secondaryFixedDim: Color(0xff8ed5b0),
      onSecondaryFixedVariant: Color(0xff005236),
      tertiaryFixed: Color(0xffc9e6ff),
      onTertiaryFixed: Color(0xff001e2f),
      tertiaryFixedDim: Color(0xff94cdf7),
      onTertiaryFixedVariant: Color(0xff004c6e),
      surfaceDim: Color(0xff101417),
      surfaceBright: Color(0xff353a3e),
      surfaceContainerLowest: Color(0xff0a0f12),
      surfaceContainerLow: Color(0xff181c20),
      surfaceContainer: Color(0xff1c2024),
      surfaceContainerHigh: Color(0xff262a2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    inputDecorationTheme: CustomInputDecorationTheme.getTheme(colorScheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade900,
      foregroundColor: Colors.white,
      centerTitle: false, // As per image alignment seems standard
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20, 
        fontWeight: FontWeight.bold, 
        color: Colors.white
      ),
    ),
  );
}
