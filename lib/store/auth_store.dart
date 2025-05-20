import 'package:get/get.dart';

class AuthStore extends GetxController {
  var user = {}.obs;
  var token = ''.obs;

  void setUser(Map<String, dynamic> newUser, String newToken) {
    user.value = newUser;
    token.value = newToken;
  }

  void clearUser() {
    user.value = {};
    token.value = '';
  }

  bool get isLoggedIn => user.isNotEmpty && token.isNotEmpty;
}
