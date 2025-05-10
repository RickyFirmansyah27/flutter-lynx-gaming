// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lynxgaming/helpers/fetch_api.dart';
import 'package:lynxgaming/helpers/download_helper.dart';
import 'dart:io';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  bool _isLoading = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = 'Mengambil data...';
  String _downloadMessage = '';
  // ignore: non_constant_identifier_names
  Map<String, dynamic>? Result;
  String? _extractPath;
  List<FileSystemEntity> _extractedFiles = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Meminta izin ketika halaman dimuat
  }

  Future<void> _requestPermissions() async {
    // Meminta izin untuk penyimpanan (untuk Android 10 ke bawah)
    var storageStatus = await Permission.storage.request();
    
    // Untuk Android 11+ (SDK 30+), minta izin manage external storage jika tersedia
    try {
      var manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) {
        print('Izin manage external storage diberikan');
        _fetchData(); // Panggil fetch data setelah mendapat izin
        return;
      }
    } catch (e) {
      print('Error requesting manage permissions: $e');
    }
    
    // Jika tidak tersedia atau ditolak, gunakan izin penyimpanan biasa
    if (storageStatus.isGranted) {
      print('Izin penyimpanan diberikan');
      _fetchData(); // Panggil fetch data setelah mendapat izin
    } else if (storageStatus.isDenied) {
      print('Izin penyimpanan ditolak');
      _showMessage('Izin penyimpanan ditolak. Beberapa fitur mungkin tidak berfungsi.');
    } else if (storageStatus.isPermanentlyDenied) {
      print('Izin penyimpanan secara permanen ditolak');
      _showMessage('Izin penyimpanan ditolak secara permanen. Silakan aktifkan di pengaturan.');
      await openAppSettings(); // Buka pengaturan untuk izin
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengambil data...';
      Result = null;
    });

    try {
      final data = await HttpHelper.get('/skins');
      setState(() {
        Result = data;
        _statusMessage = 'Data berhasil diambil!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Gagal mengambil data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndExtractFiles() async {
    if (Result == null) {
      _showMessage('Tidak ada data untuk diunduh. Ambil data terlebih dahulu.');
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadMessage = 'Mempersiapkan unduhan...';
      _extractedFiles = [];
    });

    try {
      // Ambil URL dari respons API
      final fileUrl = Result?['data']['skins'][0]['image_url'];

      if (fileUrl == null || fileUrl.isEmpty) {
        _showMessage('URL unduhan tidak ditemukan dalam data');
        setState(() {
          _isDownloading = false;
          _downloadMessage = 'Gagal: URL unduhan tidak ditemukan';
        });
        return;
      }

      setState(() {
        _downloadMessage = 'Mengunduh dari: $fileUrl';
      });

      // Download and extract the file
      final result = await DownloadHelper.downloadAndExtract7z(
        fileUrl,
        'skin_pack_${DateTime.now().millisecondsSinceEpoch}.zip', // Gunakan timestamp untuk nama unik
      );

      setState(() {
        _isDownloading = false;
        _downloadMessage = result['message'];
        _extractPath = result['extractPath'];
      });

      // Jika berhasil, tampilkan daftar file yang diekstrak
      if (result['success'] == true && result['extractPath'] != null) {
        try {
          final extractDir = Directory(result['extractPath']);
          if (await extractDir.exists()) {
            _extractedFiles = await extractDir.list().toList();
            setState(() {});
          }
        } catch (e) {
          print('Error listing extracted files: $e');
        }
      }

      _showMessage(result['message']);
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadMessage = 'Error: $e';
      });
      _showMessage('Gagal mengunduh dan mengekstrak: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uji Fetch API GET'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Refresh Data',
          ),
        ],
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
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Result != null ? Colors.green : Colors.orange,
                      ),
                    ),
                    if (_downloadMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Status Unduhan:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_isDownloading) ...[
                        LinearProgressIndicator(
                          value: _downloadProgress > 0 ? _downloadProgress / 100 : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        _downloadMessage,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _extractPath != null ? Colors.green : Colors.orange,
                        ),
                      ),
                      if (_extractPath != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Path Ekstraksi: $_extractPath',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchData,
                    icon: const Icon(Icons.refresh),
                    label: Text(_isLoading ? 'Memuat...' : 'Muat Ulang Data'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (Result == null || _isDownloading) ? null : _downloadAndExtractFiles,
                    icon: const Icon(Icons.file_download),
                    label: Text(_isDownloading ? 'Mengunduh...' : 'Unduh & Ekstrak'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_extractedFiles.isNotEmpty) ...[
              Text(
                'File yang diekstrak (${_extractedFiles.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: _extractedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _extractedFiles[index];
                    final fileName = file.path.split('/').last;
                    final isDirectory = file is Directory;
                    
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isDirectory ? Icons.folder : Icons.insert_drive_file,
                        color: isDirectory ? Colors.amber : Colors.blue,
                      ),
                      title: Text(fileName),
                      subtitle: Text(file.path),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: Result == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum ada data untuk ditampilkan'),
                        ],
                      ),
                    )
                  : Card(
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          const Text(
                            'Response dari API:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),
                          ...Result!.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.key),
                              subtitle: Text(entry.value.toString()),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Klik "Muat Ulang Data" untuk mengambil data dari API\n'
                      '2. Klik "Unduh & Ekstrak" untuk mengunduh dan mengekstrak file\n'
                      '3. Pastikan izin penyimpanan diaktifkan untuk aplikasi ini',
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