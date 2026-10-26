import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Livewave design tokens (P41 fresh purple). Mirrors design/DESIGN.md.
class LW {
  static const background = Color(0xFFF8F4FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF2EBF8);
  static const accent = Color(0xFF8E4BC7);
  static const accentFill = Color(0xFF8A43C5);
  static const accentPressed = Color(0xFF7D42AF);
  static const accentTint = Color(0xFFEEE4F7);
  static const support = Color(0xFFA8D672);
  static const supportStrong = Color(0xFF6EA22E);
  static const ink = Color(0xFF160C1F);
  static const inkSecondary = Color(0xFF54465F);
  static const inkTertiary = Color(0xFF756B80);
  static const border = Color(0xFFE6DCEF);
  static const borderStrong = Color(0xFFAE87B7);
  static const live = Color(0xFFDC2626);
  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const warning = Color(0xFFA75906);
  static const warningTint = Color(0xFFFAEFE1);
  static const danger = Color(0xFFCE2020);
  static const dangerTint = Color(0xFFFBE5E5);

  /// Dark translucent overlay used for every pill / bubble on top of video.
  static const overlay = Color(0x99160C1F);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentFill, accentPressed],
  );

  static const cardShadow = [
    BoxShadow(color: Color(0x0A160C1F), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F160C1F), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static TextStyle display({Color color = ink}) => GoogleFonts.syne(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    color: color,
    height: 1.2,
  );

  static TextStyle title({Color color = ink}) =>
      GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: color);
  static TextStyle body({Color color = ink}) =>
      GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w400, color: color);
  static TextStyle label({Color color = ink, FontWeight w = FontWeight.w500}) =>
      GoogleFonts.sora(fontSize: 14, fontWeight: w, color: color);
  static TextStyle caption({
    Color color = inkTertiary,
    FontWeight w = FontWeight.w500,
  }) => GoogleFonts.sora(fontSize: 13, fontWeight: w, color: color);
  static TextStyle small({
    Color color = inkTertiary,
    FontWeight w = FontWeight.w500,
  }) => GoogleFonts.sora(fontSize: 12, fontWeight: w, color: color);
  static TextStyle numeral({double size = 32, Color color = accent}) =>
      GoogleFonts.sora(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accentFill,
        secondary: support,
        surface: surface,
        error: danger,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.soraTextTheme(
        base.textTheme,
      ).apply(bodyColor: ink, displayColor: ink),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
