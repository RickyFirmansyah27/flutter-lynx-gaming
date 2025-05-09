import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpHelper {
  static const String _baseUrl = 'https://golang-fiber-backend.vercel.app'; // Ganti dengan URL Vercel Anda

  // Fungsi untuk GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal melakukan GET request: $e');
    }
  }

  // Fungsi untuk POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal melakukan POST request: $e');
    }
  }

  // Menangani respons dari server
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode} - ${response.body}');
    }
  }
}