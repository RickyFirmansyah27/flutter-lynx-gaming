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

      // find dragon2017 folder
      bool foundDragon2017 = false;
      for (final f in archive) {
        final pathParts = f.name.split('/');
        final dragonIndex = pathParts.indexOf('dragon2017');
        if (dragonIndex != -1) {
          foundDragon2017 = true;
          final relativePath = pathParts.sublist(dragonIndex + 1).join('/');
          if (relativePath.isEmpty) continue;

          final outPath = '$destDir/$relativePath';
          final out = File(outPath);

          if (f.isFile) {
            await out.create(recursive: true);
            await out.writeAsBytes(f.content as List<int>);
          } else {
            await Directory(outPath).create(recursive: true);
          }
        }
      }

      if (!foundDragon2017) {
        throw Exception('Folder dragon2017 tidak ditemukan di dalam zip');
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
        '${(await getExternalStorageDirectory())?.path}/downloads/dragon2017',
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
