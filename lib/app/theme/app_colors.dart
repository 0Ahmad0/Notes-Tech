import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color brand = Color(0xFF1FA8E0);

  static const List<Color> noteLightSurfaces = <Color>[
    Color(0xFFFFF3C4),
    Color(0xFFD6F5E3),
    Color(0xFFD9EEFF),
    Color(0xFFE9E0FF),
    Color(0xFFFFE2D1),
    Color(0xFFFFDDE6),
    Color(0xFFE6E9EE),
  ];

  static const List<Color> noteDarkSurfaces = <Color>[
    Color(0xFF4A4020),
    Color(0xFF204436),
    Color(0xFF1F3A50),
    Color(0xFF332C4D),
    Color(0xFF4A2F22),
    Color(0xFF4A2531),
    Color(0xFF2E3339),
  ];

  static const List<String> noteKeys = <String>[
    'yellow',
    'mint',
    'sky',
    'lavender',
    'peach',
    'rose',
    'slate',
  ];

  static Color noteSurface(String key, Brightness brightness) {
    final int index = noteKeys.indexOf(key);
    final int safeIndex = index < 0 ? 6 : index;
    return brightness == Brightness.dark
        ? noteDarkSurfaces[safeIndex]
        : noteLightSurfaces[safeIndex];
  }

  static Color onNoteSurface(String key, Brightness brightness) {
    final Color surface = noteSurface(key, brightness);
    return ThemeData.estimateBrightnessForColor(surface) == Brightness.dark
        ? Colors.white
        : const Color(0xFF1C1C1E);
  }
}
