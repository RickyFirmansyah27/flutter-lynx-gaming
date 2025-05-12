import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _baseUrl = 'https://golang-lynx-gaming.vercel.app';
  
  static Future<http.Response> makeCallApi({
    String url = '',
    String method = 'GET',
    Map<String, dynamic> params = const {},
    Map<String, dynamic> data = const {},
    Map<String, String> headers = const {},
  }) async {
    final uri = Uri.parse('$_baseUrl$url').replace(queryParameters: params.map((k, v) => MapEntry(k, v?.toString())));

    final defaultHeaders = {
      'Content-Type': 'application/json',
      ...headers,
    };

    try {
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            uri,
            headers: defaultHeaders,
          );
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: defaultHeaders,
            body: jsonEncode(data),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: defaultHeaders,
            body: jsonEncode(data),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            uri,
            headers: defaultHeaders,
          );
          break;
        default:
          throw Exception('Metode HTTP tidak didukung: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal melakukan request: $e');
    }
  }

  static Future<Map<String, dynamic>> apiGet({
    String url = '',
    Map<String, dynamic> query = const {},
    Map<String, String> headers = const {},
  }) async {
    final response = await makeCallApi(
      url: url,
      method: 'GET',
      params: query,
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> apiPost({
    String url = '',
    Map<String, dynamic> body = const {},
    Map<String, String> headers = const {},
  }) async {
    final response = await makeCallApi(
      url: url,
      method: 'POST',
      data: body,
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> apiPut({
    String url = '',
    Map<String, dynamic> body = const {},
    Map<String, String> headers = const {},
  }) async {
    final response = await makeCallApi(
      url: url,
      method: 'PUT',
      data: body,
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> apiDelete({
    String url = '',
    Map<String, String> headers = const {},
  }) async {
    final response = await makeCallApi(
      url: url,
      method: 'DELETE',
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}