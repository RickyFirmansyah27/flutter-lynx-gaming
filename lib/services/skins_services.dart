import 'package:lynxgaming/config/api_client.dart';
import 'package:lynxgaming/helpers/logger.dart';
import 'package:lynxgaming/helpers/parse_response_helper.dart';

Future<List<Map<String, dynamic>>> getAllSkins({
  Map<String, dynamic> queryParams = const {},
}) async {
  final sanitizedParams = queryParams.entries
      .where((entry) => entry.key.isNotEmpty && entry.value != null)
      .map((entry) => MapEntry(entry.key, entry.value))
      .toList();
  final validatedParams = Map<String, dynamic>.fromEntries(sanitizedParams);

  try {
    logger.d('Fetching skins with query params: $validatedParams');

    final response = await ApiClient.apiGet(
      url: '/v1/skins',
      query: validatedParams,
    );

    logger.d('Skins API response: $response');

    final skins = generateSkinResponse(response);

    if (skins.isEmpty) {
      logger.w('No skins found in response for query: $validatedParams');
    }

    return skins;
  } catch (e, stackTrace) {
   
    logger.e(
      'Unexpected error fetching skins',
      error: e,
      stackTrace: stackTrace,
    );

    return <Map<String, dynamic>>[];
  }
}