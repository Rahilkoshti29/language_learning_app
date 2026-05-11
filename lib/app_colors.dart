// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color primaryLight = Color(0xFFEEEDFF);

  // Secondary accent
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFFEEF2);

  // Success / correct
  static const Color success = Color(0xFF43C59E);
  static const Color successLight = Color(0xFFE8FBF5);

  // Warning
  static const Color warning = Color(0xFFFFB347);
  static const Color warningLight = Color(0xFFFFF4E0);

  // Error / wrong
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFFECEC);

  // Neutrals
  static const Color dark = Color(0xFF1A1A2E);
  static const Color grey = Color(0xFF6B7280);
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F7FF);

  // Language card gradients
  static const List<List<Color>> languageGradients = [
    [Color(0xFF6C63FF), Color(0xFF3B82F6)],
    [Color(0xFFFF6584), Color(0xFFFF8E53)],
    [Color(0xFF43C59E), Color(0xFF0BA360)],
    [Color(0xFFFFB347), Color(0xFFFF6584)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
  ];
}