import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:lynxgaming/services/arenas_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lynxgaming/helpers/storage_helper.dart';
import 'package:lynxgaming/helpers/message_helper.dart';
import 'package:lynxgaming/services/skins_services.dart'; // Import skins_services.dart

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _hasAccess = false;
  bool _isAndroid11OrAbove = false;
  bool _isLoading = false;
  final int _currentPage = 1;
  final int _pageSize = 5;
  List<Map<String, String>> featuredSkins = [];
  List<Map<String, String>> featuredArenas = [];

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final skins = await getAllSkins(
        queryParams: {'page': _currentPage, 'size': _pageSize},
      );
      final arenas = await getAllArenas(
        queryParams: {'page': _currentPage, 'size': _pageSize},
      );

      if (mounted) {
        setState(() {
          featuredSkins =
              skins.map((skin) {
                return {
                  'id': skin['id'].toString(),
                  'name': skin['hero'].toString(),
                  'image': skin['image_url'].toString(),
                };
              }).toList();
          featuredArenas =
              arenas.map((skin) {
                return {
                  'id': skin['id'].toString(),
                  'name': skin['nama'].toString(),
                  'image': skin['image_url'].toString(),
                };
              }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showMessage(context, 'Gagal memuat data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAccess() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    _isAndroid11OrAbove = androidInfo.version.sdkInt >= 30;
    final hasAccess = await StorageHelper.checkStoragePermission(
      isAndroid11OrAbove: _isAndroid11OrAbove,
    );
    setState(() {
      _hasAccess = hasAccess;
    });
  }

  Future<void> _snackBarAction(String message) async {
    if (!mounted) return;
    SnackBarHelper.showMessage(context, message);
  }

  Future<void> _requestStoragePermission() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (!_isAndroid11OrAbove) {
      final hasAccess = await StorageHelper.requestStoragePermission(
        isAndroid11OrAbove: false,
      );
      setState(() {
        _hasAccess = hasAccess;
      });
      if (!hasAccess) {
        if (!mounted) return;
        await _snackBarAction("Izin ditolak. Mohon aktifkan manual di pengaturan");
        await openAppSettings();
      }
    } else {
      try {
        final hasAccess = await StorageHelper.requestStoragePermission(isAndroid11OrAbove: true);
        setState(() {
          _hasAccess = hasAccess;
        });

        if (!hasAccess) {
          final intent = AndroidIntent(
            action: 'android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION',
            data: 'package:${androidInfo.packageName}',
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );

          await intent.launch();
          await _snackBarAction('Silakan aktifkan "Allow access to manage all files"');
          await Future.delayed(const Duration(seconds: 5));
          await _checkAccess();
        }
      } catch (e) {
        await _snackBarAction('Gagal membuka settings: $e');
        try {
          await openAppSettings();
        } catch (e2) {
          await _snackBarAction('Mohon buka settings dan berikan izin penyimpanan secara manual');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.pexels.com/photos/3165335/pexels-photo-3165335.jpeg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'LYNX GAMING',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Customize your gaming experience',
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 16,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(width: 2, color: Colors.amberAccent),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.amberAccent),
                        SizedBox(width: 8),
                        Text(
                          'SYSTEM OVERVIEW',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to the Lynx Gaming app. This application allows you to select, download, and install custom arena, skin assets to enhance your gaming experience.',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        if (!_hasAccess) {
                          await _requestStoragePermission();
                        }

                        final latestAccess =
                            await StorageHelper.checkStoragePermission(
                              isAndroid11OrAbove: _isAndroid11OrAbove,
                            );
                        if (latestAccess) {
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          await _snackBarAction(
                            "Akses penyimpanan diperlukan untuk lanjut.",
                          );
                        }
                      },
                      child: const Text('EXPLORE NOW'),
                    ),
                  ],
                ),
              ),

              // Featured Arenas
              Text(
                'Featured Arenas',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredArenas.length,
                  itemBuilder: (context, index) {
                    final arena = featuredArenas[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              arena['image']!,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: const Color(0xFF1E1E1E),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                width: double.infinity,
                                child: Text(
                                  arena['name']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Rajdhani',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Featured Skins
              Text(
                'Featured Skins',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : featuredSkins.isEmpty
                  ? const Center(child: Text('No skins found'))
                  : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredSkins.length,
                      itemBuilder: (context, index) {
                        final skin = featuredSkins[index];
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  skin['image']!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/placeholder.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    color: const Color(0xFF1E1E1E),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    width: double.infinity,
                                    child: Text(
                                      skin['name']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Rajdhani',
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AndroidDeviceInfo {
  String? get packageName => null;
}
