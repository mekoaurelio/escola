import 'dart:convert';
import 'dart:html' as html;

class AuthService {
  // The storage key used to save user data
  static const String _userKey = 'user';

  /// Checks if a user is logged in by looking at localStorage
  static bool isLoggedIn() {
    final userJson = html.window.localStorage[_userKey];
    if (userJson == null || userJson.isEmpty) {
      return false;
    }

    try {
      final userData = jsonDecode(userJson);
      final token = userData['token'];
      return token != null && token.isNotEmpty;
    } catch (e) {
      // Error parsing user data
      return false;
    }
  }

  /// Gets the logged in user data
  static Map<String, dynamic>? getUserData() {
    final userJson = html.window.localStorage[_userKey];
    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(userJson);
    } catch (e) {
      return null;
    }
  }

  /// Logs out the current user by clearing localStorage
  static void logout() {
    html.window.localStorage.remove(_userKey);
  }

  /// Save user data to localStorage
  static void saveUserData(Map<String, dynamic> userData) {
    final userJson = jsonEncode(userData);
    html.window.localStorage[_userKey] = userJson;
  }
}
