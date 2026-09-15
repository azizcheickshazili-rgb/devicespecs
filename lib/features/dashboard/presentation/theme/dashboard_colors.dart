import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette et typographies reprises exactement de la maquette
/// "tableau_de_bord_santé_système_mode_sombre".
class DashboardColors {
  DashboardColors._();

  static const Color background = Color(0xFF010101);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceContainerHigh = Color(0xFF272727);
  static const Color chipBackground = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF2C2B2B);
  static const Color sparklineBg = Color(0xFF141414);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF7C7979);
  static const Color textSecondary = Color(0xFFC8C6C5);
}

/// Typographies : Geist pour le texte courant, JetBrains Mono pour les
/// valeurs chiffrées / labels techniques (comme dans la maquette).
class DashboardText {
  DashboardText._();

  static TextStyle headlineMd({Color color = DashboardColors.textPrimary}) =>
      GoogleFonts.geist(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
        color: color,
      );

  static TextStyle body({Color color = DashboardColors.textMuted}) =>
      GoogleFonts.geist(fontSize: 11, color: color);

  static TextStyle labelDataSm({Color color = DashboardColors.textMuted}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 10,
        letterSpacing: 0.02,
        color: color,
      );

  static TextStyle labelDataMd({
    Color color = DashboardColors.textPrimary,
    FontWeight weight = FontWeight.w500,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: weight,
    color: color,
  );

  static TextStyle labelDataLg({Color color = DashboardColors.textPrimary}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
        color: color,
      );
}
