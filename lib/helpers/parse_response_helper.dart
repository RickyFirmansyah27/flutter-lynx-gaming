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

List<Map<String, dynamic>> generateAuthResponse(dynamic response) {
  if (response is Map<String, dynamic> &&
      response['data'] is Map<String, dynamic> &&
      response['data']['user'] is List &&
      response['data']['token'] != null) {
    final List<Map<String, dynamic>> userResponse = (response['data']['user'] as List)
        .cast<Map<String, dynamic>>()
        .toList();
    userResponse[0]['token'] = response['data']['token'];
    return userResponse;
  }
  return <Map<String, dynamic>>[];
}