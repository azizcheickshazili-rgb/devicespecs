import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette reprise exactement de la maquette "connexion_mode_sombre" /
/// "inscription_mode_sombre". Volontairement différente de la palette
/// noir/blanc du Dashboard : chaque page suit sa propre maquette.
class AuthColors {
  AuthColors._();

  static const Color surface = Color(0xFF0F131C);
  static const Color surfaceContainer = Color(0xFF1C2028);
  static const Color surfaceContainerLow = Color(0xFF181C24);
  static const Color surfaceContainerLowest = Color(0xFF0A0E16);
  static const Color surfaceContainerHigh = Color(0xFF262A33);
  static const Color surfaceContainerHighest = Color(0xFF31353E);
  static const Color surfaceVariant = Color(0xFF31353E);
  static const Color primary = Color(0xFFE0FDFF);
  static const Color primaryContainer = Color(0xFF00F2FE);
  static const Color secondary = Color(0xFFADC6FF);
  static const Color onSurfaceVariant = Color(0xFFB9CACB);
  static const Color error = Color(0xFFFFB4AB);
}

class AuthText {
  AuthText._();

  static TextStyle headline({Color color = AuthColors.primary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.015,
        color: color,
      );

  static TextStyle headlineSm({Color color = AuthColors.primary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body({Color color = AuthColors.secondary}) =>
      GoogleFonts.inter(fontSize: 14, color: color);

  static TextStyle bodySm({Color color = AuthColors.secondary}) =>
      GoogleFonts.inter(fontSize: 12, color: color);

  static TextStyle labelCaps({Color color = AuthColors.secondary}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08,
        color: color,
      );
}
