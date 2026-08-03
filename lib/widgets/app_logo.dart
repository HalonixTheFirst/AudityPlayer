import 'package:flutter/material.dart';
import '../theme.dart';

class AudityLogo extends StatelessWidget {
  final double fontSize;

  const AudityLogo({super.key, this.fontSize = 30});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          fontFamily: 'Georgia', // swap for a bundled serif (e.g. Fraunces) once you add one -- see PLAYER_README.md
        ),
        children: const [
          TextSpan(text: 'Audi', style: TextStyle(color: AudityColors.ink)),
          TextSpan(text: 'ty', style: TextStyle(color: AudityColors.brass)),
        ],
      ),
    );
  }
}
