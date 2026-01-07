import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _baseUrl = 'https://cgo0k8kcw8o08gokckkwcsgo.feeef.dev';
final _secureStorage = FlutterSecureStorage();

class AuthService {
  /// Returns true on success and stores JWT in secure storage.
  static Future<bool> login(String phone, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final token = body['token'] ?? body['access_token'] ?? body['data']?['token'];
        if (token != null && token is String && token.isNotEmpty) {
          await _secureStorage.write(key: 'jwt', value: token);
          return true;
        }
      }
    } catch (_) {
      // ignore network errors here; caller shows a generic message
    }
    return false;
  }

  static Future<void> logout() async => _secureStorage.delete(key: 'jwt');

  static Future<String?> getToken() async => _secureStorage.read(key: 'jwt');
}
