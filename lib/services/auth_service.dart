import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.55.17:9000/api/v1/auth';

  static Future<Map<String, dynamic>> register(String phone, String password, String nickname) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password, 'nickname': nickname}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? '注册失败');
  }

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    final err = jsonDecode(resp.body);
    throw Exception(err['detail'] ?? '登录失败');
  }
}
