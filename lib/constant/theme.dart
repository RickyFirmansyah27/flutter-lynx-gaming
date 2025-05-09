import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0A12);
  static const backgroundDark = Color(0xFF050508);
  static const backgroundDarker = Color(0xFF030305);
  static const cardBackground = Color(0xFF12121A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9CA3AF);
  static const accent = Color(0xFFFF4655);
  static const accentDim = Color.fromRGBO(255, 70, 85, 0.3);
  static const secondary = Color(0xFF4E54C8);
  static const success = Color(0xFF00FF88);
  static const warning = Color(0xFFFFB800);
  static const error = Color(0xFFFF4655);
}

class AppSpacing {
  static const xsmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xlarge = 32.0;
  static const xxlarge = 48.0;
  static const xxxlarge = 64.0;
}

class AppTypography {
  static const titleLarge = TextStyle(
    fontFamily: 'Orbitron',
    fontWeight: FontWeight.bold,
    fontSize: 28,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontFamily: 'Orbitron',
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: AppColors.textPrimary,
  );

  static const titleSmall = TextStyle(
    fontFamily: 'Orbitron',
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: 'Rajdhani',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Rajdhani',
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'Rajdhani',
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const buttonText = TextStyle(
    fontFamily: 'Orbitron',
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontFamily: 'Rajdhani',
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
