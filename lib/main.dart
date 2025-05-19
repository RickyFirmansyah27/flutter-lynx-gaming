import 'package:flutter/material.dart';
import 'package:lynxgaming/constant/theme.dart';
import 'package:lynxgaming/screens/layout.dart';
import 'package:lynxgaming/screens/login_screen.dart';
import 'package:lynxgaming/screens/onboarding_screen.dart';
import 'package:lynxgaming/helpers/storage_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

void main() {
  runApp(const LynxApp());
}

class LynxApp extends StatelessWidget {
  const LynxApp({super.key});

  Future<bool> _isAndroid11OrAbove() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 30;
    }
    return false;
  }

  // Fungsi untuk menentukan rute awal berdasarkan izin dan isFirstRun
  Future<String> _getInitialRoute() async {
    final isFirstRun = await StorageHelper.isFirstRun();
    if (!isFirstRun) {
      return '/login';
    }

    // Jika pertama kali, periksa izin
    final isAndroid11OrAbove = await _isAndroid11OrAbove();
    final hasPermission = await StorageHelper.checkStoragePermission(isAndroid11OrAbove: isAndroid11OrAbove);
    if (hasPermission) {
      await StorageHelper.setFirstRunComplete(); // Tandai bahwa onboarding selesai
      return '/login';
    }
    return '/'; // Ke onboarding jika belum ada izin
  }

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
      // Gunakan FutureBuilder untuk menentukan rute awal secara dinamis
      home: FutureBuilder<String>(
        future: _getInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan loading screen jika masih memeriksa
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            final initialRoute = snapshot.data!;
            if (initialRoute == '/login') {
              return const LoginScreen();
            }
            return const OnboardingScreen();
          }
          return const OnboardingScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/tabs': (context) => const TabsScreen(),
      },
    );
  }
}
