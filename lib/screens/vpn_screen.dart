import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:lynxgaming/constant/theme.dart';
import 'package:http/http.dart' as http;

class VpnScreen extends StatefulWidget {
  const VpnScreen({super.key});

  @override
  State<VpnScreen> createState() => _VpnScreenState();
}

class _VpnScreenState extends State<VpnScreen> with SingleTickerProviderStateMixin {
  bool isActive = false;
  late FlutterV2ray flutterV2ray;
  V2RayURL? v2rayURL;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  String connectionStatusText = 'Status: DISCONNECTED';
  String pingResult = '';

  final String v2rayShareLink =
      'trojan://ponselodiarrrv3hin8pt@quiz.int.vidio.com:443?path=%2Ftrojans&security=tls&host=id3.nathaya.web.id&type=ws&sni=id3.nathaya.web.id#Unlimited%20Video';
  final Uri testUri = Uri.parse('https://www.google.com');

  @override
  void initState() {
    super.initState();
    _initV2Ray();
    _initAnimation();
  }

  Future<void> _initV2Ray() async {
    flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        print('V2Ray Status: ${status.state}, Details: ${status.toString()}');
        setState(() {
          isActive = status.state == 'CONNECTED';
          connectionStatusText = 'Status: ${status.state}';
        });
      },
    );

    try {
      await flutterV2ray.initializeV2Ray();
      v2rayURL = FlutterV2ray.parseFromURL(v2rayShareLink);
      print('Parsed V2Ray Config: ${v2rayURL?.getFullConfiguration()}');
    } catch (e, stackTrace) {
      print('Error initializing V2Ray or parsing URL: $e\n$stackTrace');
      setState(() {
        connectionStatusText = 'Initialization Failed: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Initialization Failed: $e', style: AppTypography.bodySmall),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> toggleVpn() async {
    if (isActive) {
      try {
        await flutterV2ray.stopV2Ray();
        setState(() {
          isActive = false;
          connectionStatusText = 'Status: DISCONNECTED';
        });
      } catch (e) {
        print('Error stopping V2Ray: $e');
        setState(() {
          connectionStatusText = 'Stop Failed: $e';
        });
      }
    } else if (v2rayURL != null) {
      if (await flutterV2ray.requestPermission()) {
        try {
          await flutterV2ray.startV2Ray(
            remark: v2rayURL!.remark,
            config: v2rayURL!.getFullConfiguration(),
            // proxyOnly: false, // Ubah ke true jika ingin proxy selektif
            bypassSubnets: [
              '192.168.0.0/16', // Bypass jaringan lokal
              '10.0.0.0/8',     // Bypass jaringan pribadi
            ],
          );
          setState(() {
            isActive = true;
            connectionStatusText = 'Status: CONNECTED';
          });
          // Uji ping setelah koneksi berhasil
          await Future.delayed(const Duration(seconds: 2));
          if (isActive) checkPing();
        } catch (e, stackTrace) {
          print('Error starting V2Ray: $e\n$stackTrace');
          setState(() {
            connectionStatusText = 'Connection Failed: $e';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection Failed: $e', style: AppTypography.bodySmall),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        setState(() {
          connectionStatusText = 'VPN Permission Denied';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('VPN Permission Denied', style: AppTypography.bodySmall),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      setState(() {
        connectionStatusText = 'V2Ray URL is not initialized';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('V2Ray URL is not initialized', style: AppTypography.bodySmall),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> checkPing() async {
    setState(() {
      pingResult = 'Checking ping...';
    });

    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(testUri).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      setState(() {
        pingResult = response.statusCode == 200
            ? '✅ Ping success: ${stopwatch.elapsedMilliseconds}ms'
            : '⚠️ Ping failed: status ${response.statusCode}';
      });
    } on TimeoutException {
      setState(() {
        pingResult = '⏱ Timeout: no response within 5s';
      });
    } catch (e, stackTrace) {
      print('Ping error: $e\n$stackTrace');
      setState(() {
        pingResult = '❌ Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    flutterV2ray.stopV2Ray();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: toggleVpn,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isActive
                              ? AppColors.success.withOpacity(0.4)
                              : AppColors.accent.withOpacity(0.4),
                          blurRadius: _glowAnimation.value,
                          spreadRadius: _glowAnimation.value / 2,
                        ),
                      ],
                    ),
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(120),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isActive
                                ? [AppColors.success, AppColors.secondary]
                                : [AppColors.accent, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? AppColors.success : AppColors.accent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.vpn_lock,
                                  size: 48,
                                  color: isActive ? AppColors.success : AppColors.accent,
                                ),
                                const SizedBox(height: AppSpacing.small),
                                Text(
                                  isActive ? 'Disconnect' : 'Connect',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: isActive ? AppColors.success : AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              connectionStatusText,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isActive ? checkPing : null,
              child: const Text('Check Ping'),
            ),
            const SizedBox(height: 10),
            Text(
              pingResult,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}