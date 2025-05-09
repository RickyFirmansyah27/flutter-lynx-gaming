// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  Future<void> _backupFiles(BuildContext context) async {
    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur ini hanya tersedia di Android')),
      );
      return;
    }

    final hasPermission = await _requestStoragePermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin penyimpanan ditolak')),
      );
      return;
    }

    // Tentukan path sumber dan target
    const sourcePath = '/storage/emulated/0/project/mlbb-customizer/files';
    const targetPath = '/storage/emulated/0/project/backup/files';

    final sourceDir = Directory(sourcePath);
    final targetDir = Directory(targetPath);

    try {
      // Periksa apakah folder sumber ada
      if (!await sourceDir.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder sumber tidak ditemukan')),
        );
        return;
      }

      // Hitung jumlah total file untuk progres
      int totalFiles = await _countFiles(sourceDir);
      int copiedFiles = 0;

      // Tampilkan dialog loading dengan progres
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Sedang Membackup...'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Mengopi $copiedFiles dari $totalFiles file',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      // Salin folder files beserta isinya
      await _copyDirectory(
        sourceDir,
        targetDir,
        onFileCopied: () {
          copiedFiles++;
          // Perbarui UI dialog
          if (mounted) {
            setState(() {}); // Memperbarui StatefulBuilder
          }
        },
      );

      // Tutup dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup berhasil!')),
      );
    } catch (e) {
      // Tutup dialog jika ada error
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 30) {
      final manageStorage = await Permission.manageExternalStorage.request();
      return manageStorage.isGranted;
    } else {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
  }

  // Fungsi untuk menghitung jumlah total file di folder secara rekursif
  Future<int> _countFiles(Directory dir) async {
    int count = 0;
    await for (var entity in dir.list(recursive: true)) {
      if (entity is File) {
        count++;
      }
    }
    return count;
  }

  // Fungsi rekursif untuk menyalin folder dengan callback untuk progres
  Future<void> _copyDirectory(
    Directory source,
    Directory destination, {
    VoidCallback? onFileCopied,
  }) async {
    // Buat folder tujuan jika belum ada
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    // Salin semua isi folder secara rekursif
    await for (var entity in source.list(recursive: false)) {
      final entityName = entity.path.split('/').last;
      final newPath = '${destination.path}/$entityName';

      if (entity is Directory) {
        await _copyDirectory(
          entity,
          Directory(newPath),
          onFileCopied: onFileCopied,
        );
      } else if (entity is File) {
        await entity.copy(newPath);
        onFileCopied?.call(); // Panggil callback setelah file disalin
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Aplikasi')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _backupFiles(context),
          icon: const Icon(Icons.backup),
          label: const Text('Backup Sekarang'),
        ),
      ),
    );
  }
}