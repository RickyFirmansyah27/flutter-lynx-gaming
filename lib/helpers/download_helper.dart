import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:lynxgaming/helpers/logger.dart';

class DownloadHelper {
  static final Dio _dio = Dio();

  static Future<String?> downloadFile(
    String url,
    String filename, {
    Function(double)? onProgress,
  }) async {
    try {
      if (url.isEmpty || filename.isEmpty) {
        throw Exception('URL atau nama file kosong');
      }
      final dir = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/downloads',
      );
      if (!await dir.exists()) await dir.create(recursive: true);
      final path = '${dir.path}/$filename';
      final file = File(path);
      if (await file.exists()) await file.delete();

      double lastProgress = 0.0;

      await _dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;

            // Update hanya jika naik 1% atau lebih
            if ((progress - lastProgress) >= 0.01) {
              lastProgress = progress;
              onProgress?.call(progress);
            }
          }
        },
        options: Options(validateStatus: (s) => s != null && s < 500),
      );

      return await file.exists() ? path : null;
    } catch (e) {
      logger.e('Download error: $e');
      return null;
    }
  }

  static Future<bool> extractZip(String filePath, String destDir) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) throw Exception('File tidak ditemukan');
      final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
      for (final f in archive) {
        final out = File('$destDir/${f.name}');
        if (f.isFile) {
          await out.create(recursive: true);
          await out.writeAsBytes(f.content as List<int>);
        } else {
          await Directory(out.path).create(recursive: true);
        }
      }
      return true;
    } catch (e) {
      logger.e('Extract error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> downloadAndExtractZip(
    String url,
    String filename, {
    Function(double)? onProgress,
  }) async {
    try {
      final filePath = await downloadFile(
        url,
        '$filename.zip',
        onProgress: onProgress,
      );
      if (filePath == null) {
        return {'success': false, 'message': 'Gagal mengunduh'};
      }

      final baseDir = Directory(
        '${(await getExternalStorageDirectory())?.path}/downloads/$filename',
      );
      await baseDir.create(recursive: true);

      final success = await extractZip(filePath, baseDir.path);
      if (!success) {
        return {
          'success': false,
          'message': 'Ekstraksi gagal',
          'downloadPath': filePath,
        };
      }

      final files = await baseDir.list().toList();
      return {
        'success': true,
        'message': 'Berhasil',
        'downloadPath': filePath,
        'extractPath': baseDir.path,
        'fileCount': files.length,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
