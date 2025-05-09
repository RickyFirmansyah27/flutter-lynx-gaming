import 'package:flutter/material.dart';
import 'package:lynxgaming/helpers/storage_helper.dart';

class InternalAccessScreen extends StatefulWidget {
  const InternalAccessScreen({super.key});

  @override
  State<InternalAccessScreen> createState() => _InternalAccessScreenState();
}

class _InternalAccessScreenState extends State<InternalAccessScreen> {
  bool _hasAccess = false;
  String _accessStatus = "Belum memiliki akses";

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final hasAccess = await StorageHelper.checkStoragePermission();
    setState(() {
      _hasAccess = hasAccess;
      _accessStatus = StorageHelper.getAccessStatusMessage(hasAccess);
    });
  }

  Future<void> _requestStoragePermission() async {
    final hasAccess = await StorageHelper.requestStoragePermission();
    setState(() {
      _hasAccess = hasAccess;
      _accessStatus = StorageHelper.getAccessStatusMessage(hasAccess);
      if (!hasAccess) {
        _accessStatus = "Izin ditolak. Mohon aktifkan manual di pengaturan";
      }
    });
  }

  Future<void> _testAccess() async {
    final result = await StorageHelper.testStorageAccess();
    _showMessage(result);
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
        title: const Text('Akses Penyimpanan Internal'),
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
                      'Informasi:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Klik "Minta Izin Storage" untuk meminta akses penyimpanan\n'
                      '2. Jika akses diberikan, gunakan "Uji Akses" untuk memverifikasi\n'
                      '3. Aplikasi hanya akan mengakses penyimpanan internal aplikasi',
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