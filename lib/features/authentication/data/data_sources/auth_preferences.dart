import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';

class AuthPreferences {
  static const String _keyHasSeenSignUp = 'lovio_has_seen_sign_up';
  static const String _keyCachedUser = 'lovio_cached_user_profile_json';

  static Future<bool> hasSeenSignUp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasSeenSignUp) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> markSignUpSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenSignUp, true);
    } catch (_) {}
  }

  static Future<void> resetSignUpSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasSeenSignUp);
    } catch (_) {}
  }

  /// Persist complete user profile locally for instant (0ms) synchronous UI rendering
  static Future<void> saveCachedUser(UserEntity user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_keyCachedUser, userJson);
    } catch (e) {
      debugPrint('Warning: Could not save cached user: $e');
    }
  }

  /// Retrieve cached user profile instantaneously without network delays
  static Future<UserEntity?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyCachedUser);
      if (userJson != null && userJson.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        return UserEntity.fromJson(data);
      }
    } catch (e) {
      debugPrint('Warning: Could not load cached user: $e');
    }
    return null;
  }

  /// Clear cached user profile upon logout
  static Future<void> clearCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCachedUser);
    } catch (_) {}
  }
}

