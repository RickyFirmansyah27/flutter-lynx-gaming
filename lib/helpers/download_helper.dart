import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

class DownloadHelper {
  static final Dio _dio = Dio();
  
  // Fungsi untuk mengunduh file
  static Future<String?> downloadFile(String url, String filename) async {
    try {
      // Pastikan URL dan filename valid
      if (url.isEmpty || filename.isEmpty) {
        throw Exception('URL atau nama file tidak valid');
      }
      
      // Dapatkan direktori penyimpanan
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/downloads');
      
      // Buat direktori jika belum ada
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      
      final filePath = '${downloadDir.path}/$filename';
      
      // Hapus file lama jika ada
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Unduh file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
        options: Options(
          headers: {
            'Accept': '*/*',
          },
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          }
        ),
      );
      
      // Verifikasi file berhasil diunduh
      if (await File(filePath).exists()) {
        print('File berhasil diunduh ke: $filePath');
        return filePath;
      } else {
        throw Exception('File tidak ditemukan setelah mengunduh');
      }
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }
  
  // Fungsi untuk mengenali dan mengekstrak file berdasarkan ekstensinya
  static Future<bool> extractFile(String filePath, String destinationDir) async {
    try {
      final destination = Directory(destinationDir);
      if (!await destination.exists()) {
        await destination.create(recursive: true);
      }
      
      // Cek ekstensi file
      final extension = filePath.split('.').last.toLowerCase();
      
      if (extension == 'zip') {
        return await _extractZipFile(filePath, destinationDir);
      } else if (extension == '7z') {
        // Untuk file 7z, gunakan metode alternatif karena archive package tidak mendukung langsung
        // Opsi 1: Gunakan library lain seperti flutter_archive atau flutter_7zip jika tersedia
        print('WARNING: Ekstraksi file 7z mungkin memerlukan library khusus');
        return await _extractAsZipFile(filePath, destinationDir);
      } else {
        // Coba ekstrak sebagai ZIP - bisa jadi file ZIP dengan ekstensi berbeda
        return await _extractAsZipFile(filePath, destinationDir);
      }
    } catch (e) {
      print('Error extracting file: $e');
      return false;
    }
  }
  
  // Ekstrak file ZIP
  static Future<bool> _extractZipFile(String filePath, String destinationDir) async {
    try {
      print('Mengekstrak file ZIP: $filePath ke $destinationDir');
      
      // Pastikan file ada
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File tidak ditemukan: $filePath');
      }
      
      // Baca file sebagai bytes
      final bytes = await file.readAsBytes();
      
      // Decode archive
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // Ekstrak semua file
      for (final file in archive) {
        final outPath = '$destinationDir/${file.name}';
        print('Extracting: ${file.name}');
        
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }
      
      return true;
    } catch (e) {
      print('Error extracting ZIP file: $e');
      return false;
    }
  }
  
  // Mencoba ekstrak file sebagai ZIP meskipun ekstensinya bukan .zip
  static Future<bool> _extractAsZipFile(String filePath, String destinationDir) async {
    try {
      print('Mencoba ekstrak file sebagai ZIP: $filePath');
      
      // Buka file sebagai stream
      final inputStream = InputFileStream(filePath);
      Archive? archive;
      
      try {
        // Coba dekode sebagai ZIP
        archive = ZipDecoder().decodeStream(inputStream);
      } catch (e) {
        print('File bukan format ZIP: $e');
        inputStream.close();
        return false;
      }
      
      if (archive == null) {
        print('Gagal mendekode archive');
        return false;
      }
      
      // Ekstrak semua file
      for (final file in archive) {
        final outPath = '$destinationDir/${file.name}';
        
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }
      
      return true;
    } catch (e) {
      print('Error extracting as ZIP: $e');
      return false;
    }
  }
  
  // Fungsi untuk mengunduh dan mengekstrak file
  static Future<Map<String, dynamic>> downloadAndExtract7z(String url, String filename) async {
    try {
      print('Memulai unduh dan ekstrak file: $url');
      
      // Verifikasi URL
      if (url.isEmpty) {
        return {
          'success': false,
          'message': 'URL unduhan kosong atau tidak valid'
        };
      }
      
      // Unduh file
      final downloadedFilePath = await downloadFile(url, filename);
      if (downloadedFilePath == null) {
        return {
          'success': false,
          'message': 'Gagal mengunduh file dari $url'
        };
      }
      
      print('File berhasil diunduh: $downloadedFilePath');
      
      // Buat direktori untuk ekstraksi
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extractDir = '${appDir.path}/extracted_$timestamp';
      
      print('Akan mengekstrak ke direktori: $extractDir');
      
      // Ekstrak file
      final extractSuccess = await extractFile(downloadedFilePath, extractDir);
      if (!extractSuccess) {
        return {
          'success': false,
          'message': 'Gagal mengekstrak file. Format file mungkin tidak didukung.',
          'downloadPath': downloadedFilePath
        };
      }
      
      // Verifikasi hasil ekstraksi
      final extractDir2 = Directory(extractDir);
      final files = await extractDir2.list().toList();
      print('File hasil ekstraksi: ${files.length}');
      
      if (files.isEmpty) {
        return {
          'success': false,
          'message': 'Ekstraksi selesai tetapi tidak ada file yang ditemukan',
          'downloadPath': downloadedFilePath,
          'extractPath': extractDir
        };
      }
      
      return {
        'success': true,
        'message': 'Berhasil mengunduh dan mengekstrak file',
        'downloadPath': downloadedFilePath,
        'extractPath': extractDir,
        'fileCount': files.length
      };
    } catch (e) {
      print('Error saat mengunduh dan mengekstrak: $e');
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }
}