import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lynxgaming/helpers/logger.dart';

class AuthStore extends GetxController {
  var user = {}.obs;
  var token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedUserJson = prefs.getString('user_data');

      if (savedToken != null && savedToken.isNotEmpty && savedUserJson != null) {
        token.value = savedToken;
        user.value = json.decode(savedUserJson);
        logger.i('Loaded user data from storage');
      }
    } catch (e) {
      logger.e('Error loading user data: $e');
    }
  }

  Future<void> setUser(Map<String, dynamic> newUser, String newToken) async {
    try {
      user.value = newUser;
      token.value = newToken;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', newToken);
      await prefs.setString('user_data', json.encode(newUser));
      logger.i('Saved user data to storage');
    } catch (e) {
      logger.e('Error saving user data: $e');
    }
  }

  Future<void> clearUser() async {
    try {
      user.value = {};
      token.value = '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      logger.i('Cleared user data from storage');
    } catch (e) {
      logger.e('Error clearing user data: $e');
    }
  }

  bool get isLoggedIn => user.isNotEmpty && token.isNotEmpty;
}
