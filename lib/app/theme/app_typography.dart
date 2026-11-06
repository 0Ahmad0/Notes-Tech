import 'package:flutter/material.dart';

abstract final class AppTypography {
  static TextTheme textTheme(Brightness brightness, {String? fontFamily}) {
    final TextTheme base = brightness == Brightness.dark
        ? Typography.material2021(platform: TargetPlatform.iOS).white
        : Typography.material2021(platform: TargetPlatform.iOS).black;
    final TextTheme themed = fontFamily == null
        ? base
        : base.apply(fontFamily: fontFamily);
    return themed.copyWith(
      displaySmall: themed.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      headlineSmall: themed.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: themed.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleMedium: themed.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: themed.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: themed.bodyMedium?.copyWith(height: 1.45),
      labelLarge: themed.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}
