List<Map<String, dynamic>> generateArenaResponse(dynamic response) {
  if (response is Map<String, dynamic> &&
      response['data'] is Map<String, dynamic> &&
      response['data']['arenas'] is List) {
    return (response['data']['arenas'] as List)
        .cast<Map<String, dynamic>>()
        .toList();
  }
  return <Map<String, dynamic>>[];
}

List<Map<String, dynamic>> generateSkinResponse(dynamic response) {
  if (response is Map<String, dynamic> &&
      response['data'] is Map<String, dynamic> &&
      response['data']['skins'] is List) {
    return (response['data']['skins'] as List)
        .cast<Map<String, dynamic>>()
        .toList();
  }
  return <Map<String, dynamic>>[];
}

Map<String, dynamic> generateAuthResponse(dynamic response) {
  if (response is Map<String, dynamic> &&
      response['data'] is Map<String, dynamic> &&
      response['data']['token'] != null &&
      response['data']['user'] is Map<String, dynamic>) {
    return {
      'token': response['data']['token'],
      'user': response['data']['user']
    };
  }
  return {};
}