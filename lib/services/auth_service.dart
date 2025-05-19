import 'package:lynxgaming/config/api_client.dart';
import 'package:lynxgaming/helpers/logger.dart';
import 'package:lynxgaming/helpers/parse_response_helper.dart';

Future<List<Map<String, dynamic>>> authLogin({
  Map<String, dynamic> bodyRequest = const {},
}) async {

  try {
    final response = await ApiClient.apiPost(
      url: '/v1/login',
      body: bodyRequest,
    );

    logger.d('Login API response: $response');
    final auth = generateAuthResponse(response);

    return [auth];
  } catch (e, stackTrace) {
   
    logger.e(
      'Unexpected error login',
      error: e,
      stackTrace: stackTrace,
    );

    return <Map<String, dynamic>>[];
  }
}