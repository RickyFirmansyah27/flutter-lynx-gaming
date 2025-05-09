import 'package:flutter/material.dart';
import 'package:lynxgaming/helpers/fetch_api.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Tekan tombol untuk mengambil data';
  Map<String, dynamic>? _apiData;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengambil data...';
      _apiData = null;
    });

    try {
      // Ganti '/api/data' dengan endpoint GET Anda di Vercel
      final data = await HttpHelper.get('/v1/items');
      setState(() {
        _apiData = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uji Fetch API GET'),
        backgroundColor: Colors.blue,
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
                        color: _apiData != null ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchData,
              icon: const Icon(Icons.cloud_download),
              label: Text(_isLoading ? 'Mengambil...' : 'Ambil Data dari Vercel'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _apiData == null
                  ? const Center(child: Text('Belum ada data untuk ditampilkan'))
                  : Card(
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: _apiData!.entries.map((entry) {
                          return ListTile(
                            title: Text(entry.key),
                            subtitle: Text(entry.value.toString()),
                          );
                        }).toList(),
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
                      '1. Klik "Ambil Data dari Vercel" untuk menguji panggilan GET\n'
                      '2. Data akan ditampilkan dalam daftar jika berhasil\n'
                      '3. Pastikan backend Vercel memiliki endpoint /api/data',
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