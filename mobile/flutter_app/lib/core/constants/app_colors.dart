import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color backgroundDark = Color(0xFF0F0F13); // Deep dark for neon
  static const Color backgroundLight = Color(0xFFF7F7F9);
  
  static const Color surfaceDark = Color(0xFF1C1C23);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF1C1C23);
  
  static const Color textSecondaryDark = Color(0xFFA0A0AB);
  static const Color textSecondaryLight = Color(0xFF6E6E73);

  // Accent & Action Colors
  static const Color primaryNeon = Color(0xFF6366F1); // Indigo (White/Purple Theme)
  static const Color secondaryNeon = Color(0xFF8B5CF6); // Purple
  
  // University Specific Colors (Mock)
  static const Color uniTechPrimary = Color(0xFF0055FF);
  static const Color uniArtPrimary = Color(0xFFFF5500);

  static Color getUniversityColor(String universityCode) {
    switch (universityCode) {
      case 'TECH':
        return uniTechPrimary;
      case 'ART':
        return uniArtPrimary;
      default:
        return primaryNeon;
    }
  }
}
