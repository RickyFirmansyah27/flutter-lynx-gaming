import 'package:lynxgaming/config/api_client.dart';
import 'package:lynxgaming/helpers/logger.dart';
import 'package:lynxgaming/helpers/parse_response_helper.dart';

Future<List<Map<String, dynamic>>> getAllArenas({
  Map<String, dynamic> queryParams = const {},
}) async {
  final sanitizedParams = queryParams.entries
      .where((entry) => entry.key.isNotEmpty && entry.value != null)
      .map((entry) => MapEntry(entry.key, entry.value))
      .toList();
  final validatedParams = Map<String, dynamic>.fromEntries(sanitizedParams);

  try {
    logger.d('Fetching arenas with query params: $validatedParams');

    final response = await ApiClient.apiGet(
      url: '/v1/arenas',
      query: validatedParams,
    );

    logger.d('Arenas API response: $response');

    final arenas = generateArenaResponse(response);

    if (arenas.isEmpty) {
      logger.w('No arenas found in response for query: $validatedParams');
    }

    return arenas;
  } catch (e, stackTrace) {
    logger.e(
      'Unexpected error fetching arenas',
      error: e,
      stackTrace: stackTrace,
    );

    return <Map<String, dynamic>>[];
  }
}
