// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
// Pastikan path ini sesuai dengan lokasi StorageHelper Anda
import 'package:lynxgaming/helpers/storage_helper.dart';

class AndroidDataAccessScreen extends StatefulWidget {
  const AndroidDataAccessScreen({super.key});

  @override
  State<AndroidDataAccessScreen> createState() => _AndroidDataAccessScreenState();
}

class _AndroidDataAccessScreenState extends State<AndroidDataAccessScreen> {
  bool _hasAccess = false;
  String _accessStatus = "Belum memiliki akses";
  late bool _isAndroid11OrAbove;
  String _androidVersion = '';

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    _isAndroid11OrAbove = androidInfo.version.sdkInt >= 30;
    _androidVersion = androidInfo.version.release;

    // Cek izin menggunakan StorageHelper
    final hasAccess = await StorageHelper.checkStoragePermission(isAndroid11OrAbove: _isAndroid11OrAbove);
    setState(() {
      _hasAccess = hasAccess;
      _accessStatus = StorageHelper.getAccessStatusMessage(
        hasAccess,
        isAndroid11OrAbove: _isAndroid11OrAbove,
        androidVersion: _androidVersion,
      );
    });

    // Cek apakah sudah pernah diberi akses lewat SAF
    final prefs = await SharedPreferences.getInstance();
    final hasUriPermission = prefs.getBool('has_android_data_access') ?? false;
    if (hasUriPermission) {
      setState(() {
        _accessStatus += " (SAF)";
      });
    }
  }

  Future<void> _requestStoragePermission() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (!_isAndroid11OrAbove) {
      // Untuk Android 10 ke bawah
      final hasAccess = await StorageHelper.requestStoragePermission(isAndroid11OrAbove: false);
      setState(() {
        _hasAccess = hasAccess;
        _accessStatus = StorageHelper.getAccessStatusMessage(
          hasAccess,
          isAndroid11OrAbove: false,
          androidVersion: androidInfo.version.release,
        );
      });
      if (!hasAccess) {
        _showMessage("Izin ditolak. Mohon aktifkan manual di pengaturan");
        await openAppSettings();
      }
    } else {
      // Untuk Android 11 ke atas
      try {
        final hasAccess = await StorageHelper.requestStoragePermission(isAndroid11OrAbove: true);
        setState(() {
          _hasAccess = hasAccess;
          _accessStatus = StorageHelper.getAccessStatusMessage(
            hasAccess,
            isAndroid11OrAbove: true,
            androidVersion: androidInfo.version.release,
          );
        });

        if (!hasAccess) {
          // Membuka halaman settings untuk "All files access permission"
          final intent = AndroidIntent(
            action: 'android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION',
            data: 'package:${androidInfo.packageName}',
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );

          await intent.launch();
          _showMessage('Silakan aktifkan "Allow access to manage all files"');

          // Cek ulang izin setelah beberapa detik
          await Future.delayed(const Duration(seconds: 5));
          await _checkAccess();
        }
      } catch (e) {
        _showMessage('Gagal membuka settings: $e');
        try {
          await openAppSettings();
        } catch (e2) {
          _showMessage('Mohon buka settings dan berikan izin penyimpanan secara manual');
        }
      }
    }
  }

  Future<void> _openSAFForAndroidData() async {
    final intent = AndroidIntent(
      action: 'android.intent.action.OPEN_DOCUMENT_TREE',
      flags: <int>[
        Flag.FLAG_GRANT_READ_URI_PERMISSION,
        Flag.FLAG_GRANT_WRITE_URI_PERMISSION,
        Flag.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
        Flag.FLAG_ACTIVITY_NEW_TASK,
      ],
    );

    try {
      await intent.launch();

      // Simpan flag ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_android_data_access', true);

      // Update status setelah delay singkat
      await Future.delayed(const Duration(seconds: 3));
      await _checkAccess();
    } catch (e) {
      _showMessage('Gagal membuka SAF: $e');
    }
  }

  Future<void> _testAccess() async {
    try {
      // Coba tulis file test di internal storage
      final appDir = await getExternalStorageDirectory();
      if (appDir == null) {
        _showMessage('Tidak dapat menemukan external storage directory');
        return;
      }

      final testFile = File('${appDir.path}/test_write.txt');
      await testFile.writeAsString('Test akses tulis: ${DateTime.now()}');
      _showMessage('Dapat menulis file di folder aplikasi');
    } catch (e) {
      _showMessage('Gagal menulis file di folder aplikasi: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akses Android/data'),
        backgroundColor: _hasAccess ? Colors.green : Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Status Akses:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _accessStatus,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _hasAccess ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _requestStoragePermission,
              icon: const Icon(Icons.folder),
              label: const Text('Minta Izin Storage'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _openSAFForAndroidData,
              icon: const Icon(Icons.folder_open),
              label: const Text('Buka Folder dengan SAF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _testAccess,
              icon: const Icon(Icons.check_circle),
              label: const Text('Uji Akses'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cara Mendapatkan Akses Android/data:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Untuk Android 10 ke bawah: Cukup berikan izin storage biasa\n'
                      '2. Untuk Android 11 ke atas:\n'
                      '   - Gunakan tombol "Minta Izin Storage" (memerlukan opsi All Files Access)\n'
                      '   - ATAU gunakan "Buka Folder dengan SAF" dan berikan akses permanen\n'
                      '3. Jika akses sudah berhasil, tombol "Uji Akses" seharusnya bekerja',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on AndroidDeviceInfo {
  get packageName => null;
}
