// ignore_for_file: avoid_print

import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StorageHelper {
  // Memeriksa status izin penyimpanan
  static Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  // Meminta izin penyimpanan
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      await openAppSettings();
    }
    return status.isGranted;
  }

  // Mendapatkan pesan status akses
  static String getAccessStatusMessage(bool hasAccess) {
    return hasAccess
        ? "Memiliki akses ke penyimpanan internal"
        : "Belum memiliki akses ke penyimpanan internal";
  }

  // Menguji akses baca/tulis penyimpanan
  static Future<String> testStorageAccess() async {
    try {
      final appDir = await getExternalStorageDirectory();
      if (appDir == null) {
        print('Tidak dapat menemukan external storage directory');
      }
      
      final testFile = File('${appDir}/test_write.txt');
      await testFile.writeAsString('Test akses tulis: ${DateTime.now()}');
      final content = await testFile.readAsString();
      return 'Berhasil menulis dan membaca file di penyimpanan internal!\nIsi: $content';
    } catch (e) {
      return 'Gagal mengakses penyimpanan internal: $e';
    }
  }
}