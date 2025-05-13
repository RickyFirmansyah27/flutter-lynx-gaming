import 'package:lynxgaming/config/api_client.dart';

Future<List<Map<String, dynamic>>> getAllSkins({
  Map<String, dynamic> queryParams = const {},
}) async {
  final response = await ApiClient.apiGet(
    url: '/v1/skins',
    query: queryParams,
  );

  return List<Map<String, dynamic>>.from(response['data']['skins'] ?? []);
}
