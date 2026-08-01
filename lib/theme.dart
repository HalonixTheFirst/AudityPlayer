import 'package:flutter/material.dart';

/// Colors lifted directly from the web app's index.css so the player feels
/// like the same product, not a different app that happens to share a name.
class AudityColors {
  static const bg = Color(0xFF16231F); // --bg
  static const surface = Color(0xFF1E2E29); // --surface
  static const surfaceRaised = Color(0xFF253730); // --surface-raised
  static const line = Color(0xFF34473F); // --line
  static const ink = Color(0xFFF2EEE3); // --ink (paper white)
  static const inkMuted = Color(0xFF93A39A); // --ink-muted
  static const brass = Color(0xFFC9A227); // --brass
  static const brassSoft = Color(0x29C9A227); // --brass-soft (~16% alpha)
  static const teal = Color(0xFF4FA89B); // --teal
  static const danger = Color(0xFFD9694F); // --danger
}

class AudityTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AudityColors.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: AudityColors.brass,
        secondary: AudityColors.teal,
        surface: AudityColors.surface,
        error: AudityColors.danger,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AudityColors.ink,
        displayColor: AudityColors.ink,
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AudityColors.teal,
        inactiveTrackColor: AudityColors.line,
        thumbColor: AudityColors.teal,
        overlayColor: AudityColors.teal.withOpacity(0.2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AudityColors.bg,
        foregroundColor: AudityColors.ink,
        elevation: 0,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: AudityColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AudityColors.line, width: 1),
        ),
      ),
    );
  }
}
