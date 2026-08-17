import 'package:flutter/material.dart';

/// AppColors defines the Apple-inspired minimalist and premium enterprise
/// color palette tailored for an Umrah monitoring application with high contrast
/// boundaries and crystal clear readability specifically designed for elderly pilgrims.
class AppColors {
  AppColors._();

  // Primary Royal Crimson Red Palette (#740A03)
  static const Color primary = Color(0xFF740A03); // Deep Royal Crimson Red (#740A03)
  static const Color primaryLight = Color(0xFF9E160B); // Bright crimson tint
  static const Color primaryDark = Color(0xFF490501); // Deep rich crimson dark
  static const Color primaryContainer = Color(0xFFFDECEB); // Soft crimson rose container
  static const Color onPrimaryContainer = Color(0xFF490501);

  // Secondary Brighter Luminous Gold Accent (Supporting Elements)
  static const Color secondary = Color(0xFFE6C200); // Shimmering 24K Royal Gold (#E6C200 - brighter gold)
  static const Color secondaryLight = Color(0xFFF4D03F); // Luminous Golden Sun (#F4D03F for ultra clear high contrast)
  static const Color secondaryDark = Color(0xFFA8891C); // Burnished gold border
  static const Color secondaryContainer = Color(0xFFFEF9E7); // Bright golden sun container
  static const Color onSecondaryContainer = Color(0xFF5D4807);

  // Backgrounds & Surface (Minimalist Apple Aesthetic with High-Contrast Boundaries)
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure white background for ultra clean modern Apple aesthetic
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF1E242C);

  // Text & Content Colors (High Contrast for Elderly Eyes)
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900 - maximum readability near-black
  static const Color textSecondaryLight = Color(0xFF334155); // Slate 700 - high contrast dark gray for subtitles & info
  static const Color textTertiaryLight = Color(0xFF64748B); // Slate 500

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);

  // Borders & Dividers (Sharp, Distinct Container Boundaries)
  static const Color borderLight = Color(0xFFCBD5E1); // Crisp Slate 300 for distinct card & button boundaries
  static const Color borderDark = Color(0xFF475569); // Crisp Slate 600 for dark mode distinction

  // Functional & Supporting Status Colors
  static const Color emergencyRed = Color(0xFFD92D20); // High contrast red
  static const Color emergencyContainer = Color(0xFFFDEDEE);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color successGreen = Color(0xFF16A34A); // High contrast emerald green for verification status
  static const Color infoBlue = Color(0xFF1D4ED8);

  // Shadow specifications (High-definition contrast shadows for floating Apple look)
  static List<BoxShadow> get softShadowLight => [
    BoxShadow(
      color: Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get softShadowDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}
