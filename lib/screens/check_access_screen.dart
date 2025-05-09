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

class AndroidDataAccessScreen extends StatefulWidget {
  const AndroidDataAccessScreen({super.key});

  @override
  State<AndroidDataAccessScreen> createState() => _AndroidDataAccessScreenState();
}

class _AndroidDataAccessScreenState extends State<AndroidDataAccessScreen> {
  bool _hasAccess = false;
  String _accessStatus = "Belum memiliki akses";

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    // Untuk Android 10 ke bawah, cek izin storage biasa
    if (androidInfo.version.sdkInt < 30) {
      final status = await Permission.storage.status;
      setState(() {
        _hasAccess = status.isGranted;
        _accessStatus = status.isGranted 
            ? "Memiliki akses (Android ${androidInfo.version.release})"
            : "Belum memiliki akses";
      });
      return;
    }
    
    // Untuk Android 11 ke atas, cek izin MANAGE_EXTERNAL_STORAGE
    final status = await Permission.manageExternalStorage.status;
    setState(() {
      _hasAccess = status.isGranted;
      _accessStatus = status.isGranted 
          ? "Memiliki akses lengkap (Android ${androidInfo.version.release})"
          : "Belum memiliki akses lengkap";
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
    
    if (androidInfo.version.sdkInt < 30) {
      // Untuk Android 10 ke bawah
      final status = await Permission.storage.request();
      setState(() {
        _hasAccess = status.isGranted;
        _accessStatus = status.isGranted 
            ? "Memiliki akses (Android ${androidInfo.version.release})"
            : "Izin ditolak. Mohon aktifkan manual di pengaturan";
      });
      
      if (!status.isGranted) {
        await openAppSettings();
      }
    } else {
      // Untuk Android 11 ke atas, kita perlu membuka settings secara eksplisit
      // karena permission dialog tidak muncul otomatis untuk MANAGE_EXTERNAL_STORAGE
      try {
        // Mencoba status terlebih dahulu
        final status = await Permission.manageExternalStorage.status;
        
        if (status.isGranted) {
          setState(() {
            _hasAccess = true;
            _accessStatus = "Memiliki akses lengkap (Android ${androidInfo.version.release})";
          });
          return;
        }
        
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
        _checkAccess();
      } catch (e) {
        // Fallback jika intent tidak berhasil
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
      
      // Idealnya di sini kita akan mendapatkan URI hasil dari SAF picker
      // dan menyimpannya untuk penggunaan di masa mendatang
      // Namun karena batasan plugin, ini perlu handling di Activity Result
      
      // Untuk contoh ini, kita simpan flag ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_android_data_access', true);
      
      // Update status setelah delay singkat
      await Future.delayed(const Duration(seconds: 3));
      _checkAccess();
      
    } catch (e) {
      _showMessage('Gagal membuka SAF: $e');
    }
  }

  Future<void> _testAccess() async {
  /// Menguji akses aplikasi ke penyimpanan internal dan eksternal.
  ///
  /// Fungsi ini akan mencoba menulis file di internal storage dan
  /// mengakses folder Android/data. Jika akses berhasil, maka akan
  /// menampilkan pesan "Berhasil menulis file di Android/data!".
  /// Jika akses gagal, maka akan menampilkan pesan error yang
  /// sesuai.
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
      
      // Mencoba akses folder Android/data
      // Ini akan gagal tanpa SAF atau MANAGE_EXTERNAL_STORAGE
      String? androidDataPath;
      try {
        // Coba mendapatkan path lengkap ke Android/data
        // Ini akan bekerja pada beberapa device, tapi tidak semua
        // ignore: prefer_interpolation_to_compose_strings
        androidDataPath = appDir.path.split('Android')[0] + 'Android/data';
      } catch (e) {
        // Fallback method untuk mencari Android/data
        try {
          Directory? storageDir;
          if (Platform.isAndroid) {
            // Mencoba mendapatkan external storage root
            final result = await Process.run('stat', ['-c', '%m', '/storage/emulated/0']);
            final output = result.stdout.toString().trim();
            if (output.isNotEmpty) {
              storageDir = Directory('/storage/emulated/0');
            }
          }
          
          if (storageDir != null) {
            androidDataPath = '${storageDir.path}/Android/data';
          }
        } catch (e) {
          _showMessage('Tidak dapat menemukan path Android/data: $e');
          return;
        }
      }
      
      if (androidDataPath == null) {
        _showMessage('Tidak dapat menentukan path Android/data');
        return;
      }
      
      // Debug info
      _showMessage('Mencoba akses path: $androidDataPath');
      
      final directory = Directory(androidDataPath);
      final exists = await directory.exists();
      
      if (exists) {
        try {
          final contents = directory.listSync();
          _showMessage('SUKSES! Dapat mengakses ${contents.length} item di Android/data');
          
          // Mencoba menulis file di Android/data untuk memastikan write access
          try {
            final testDataFile = File('$androidDataPath/test_app_access.txt');
            await testDataFile.writeAsString('Test akses: ${DateTime.now()}');
            _showMessage('Berhasil menulis file di Android/data!');
          } catch (e) {
            _showMessage('Dapat membaca tapi tidak menulis: $e');
          }
        } catch (e) {
          _showMessage('Folder ada tapi tidak bisa dibaca: $e');
        }
      } else {
        _showMessage('Folder Android/data tidak ditemukan di $androidDataPath');
      }
    } catch (e) {
      _showMessage('Error saat mengakses penyimpanan: $e');
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
