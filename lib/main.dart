import 'package:flutter/material.dart';
import 'package:lynxgaming/constant/theme.dart';
import 'package:lynxgaming/screens/layout.dart';
import 'package:lynxgaming/screens/login_screen.dart';
import 'package:lynxgaming/screens/onboarding_screen.dart';

void main() {
  runApp(const LynxApp());
}

class LynxApp extends StatelessWidget {
  const LynxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lynx Gaming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        colorScheme: ColorScheme.dark(
          surface: AppColors.background,
          primary: AppColors.accent,
          secondary: AppColors.secondary,
          error: AppColors.error,
        ),
        textTheme: const TextTheme(
          headlineLarge: AppTypography.titleLarge,
          headlineMedium: AppTypography.titleMedium,
          headlineSmall: AppTypography.titleSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.buttonText,
          labelSmall: AppTypography.caption,
        ),
        useMaterial3: true,
        fontFamily: 'Rajdhani',
      ),
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/tabs': (context) => const TabsScreen(),
        '/': (context) => const OnboardingScreen(),
      },
    );
  }
}
