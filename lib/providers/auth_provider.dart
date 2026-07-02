import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _nickname;
  String? _userId;
  bool _loading = false;

  String? get token => _token;
  String? get nickname => _nickname;
  String? get userId => _userId;
  bool get isLoggedIn => _token != null;
  bool get loading => _loading;

  Future<void> login(String phone, String password) async {
    _loading = true; notifyListeners();
    try {
      final result = await AuthService.login(phone, password);
      _token = result['token'];
      _nickname = result['user']['nickname'];
      _userId = result['user']['id'];
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> register(String phone, String password, String nickname) async {
    _loading = true; notifyListeners();
    try {
      await AuthService.register(phone, password, nickname);
      await login(phone, password);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  void logout() {
    _token = null; _nickname = null; _userId = null;
    notifyListeners();
  }
}
