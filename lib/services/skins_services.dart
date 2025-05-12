import 'package:lynxgaming/config/api_client.dart';

Future<List<Map<String, dynamic>>> getAllSkins() async {
  final response = await ApiClient.apiGet(url: '/v1/skins');
  return List<Map<String, dynamic>>.from(response['data']['skins'] ?? []);
}