import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("🔑 Token: ${token.isEmpty ? 'EMPTY ❌' : 'OK ✅ (${token.substring(0, token.length > 20 ? 20 : token.length)}...)'}");
    return {
      "Content-Type": "application/json",
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // 1. Add Points
  static Future<void> addPoints(int userId, int pointsToAdd) async {
    final url = Uri.parse("$baseUrl/add-points");
    try {
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({
          "userId": userId,
          "pointsToAdd": pointsToAdd,
        }),
      );
      if (response.statusCode == 200) {
        print("✅ Points updated successfully");
      } else {
        print("❌ Failed to update points: ${response.body}");
      }
    } catch (e) {
      print("❌ Connection Error: $e");
    }
  }

  // 2. Save Game Session
  static Future<void> saveGameSession({
    required int userId,
    required String gameName,
    required int pointsEarned,
  }) async {
    final url = Uri.parse("$baseUrl/game-session");
    try {
      // Debug: print all keys in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      print("📦 SharedPreferences keys: $keys");
      final token = prefs.getString('token') ?? '';
      print("🎮 Saving session — token empty: ${token.isEmpty}");

      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({
          "userId": userId,
          "gameName": gameName,
          "pointsEarned": pointsEarned,
        }),
      );
      if (response.statusCode == 200) {
        print("✅ Game session saved: $gameName, +$pointsEarned pts");
      } else {
        print("❌ Failed to save game session: ${response.body}");
      }
    } catch (e) {
      print("❌ Error saving game session: $e");
    }
  }

  // 3. Login — saves token
  static Future<bool> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        print("✅ Token saved via ApiService.login()");
        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // 4. Register
  static Future<bool> register(String username, String password) async {
    final url = Uri.parse("$baseUrl/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password, "role": "parent"}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  // 5. Get user stats
  static Future<Map<String, dynamic>?> getUserStats(int userId) async {
    final url = Uri.parse("$baseUrl/user-stats/$userId");
    try {
      final response = await http.get(url, headers: await _authHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("❌ Error getting user stats: $e");
    }
    return null;
  }
}