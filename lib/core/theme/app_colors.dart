import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Energetic & Motivating
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color primaryPink = Color(0xFFFF6B6B);

  // Secondary
  static const Color secondaryPurple = Color(0xFF8B5CF6);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color secondaryGreen = Color(0xFF10B981);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFD93D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Colors
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryFitness = Color(0xFFFF6B35);
  static const Color categoryMindfulness = Color(0xFF8B5CF6);
  static const Color categoryProductivity = Color(0xFF3B82F6);
  static const Color categoryLearning = Color(0xFFFFD93D);
  static const Color categorySocial = Color(0xFFEC4899);

  // Streak Colors
  static const Color streakFire = Color(0xFFFF6B35);
  static const Color streakGold = Color(0xFFFFD93D);
  static const Color streakIce = Color(0xFF60A5FA);

  // Background - Clean White Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundLightCard = Color(0xFFFFFFFF);
  static const Color backgroundLightElevated = Color(0xFFF1F5F9);

  // Background - Dark Mode (rich navy, not black)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundDarkCard = Color(0xFF1E293B);
  static const Color backgroundDarkElevated = Color(0xFF2D3A4E);

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFE2E8F0);
  static const Color textTertiaryDark = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Glassmorphism
  static const Color glassBorder = Color(0x0D000000);
}
