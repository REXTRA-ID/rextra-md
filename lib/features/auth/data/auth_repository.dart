import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../../../core/storage/secure_storage.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository(this._service);
  final AuthService _service;

  bool _loading = false;
  bool get loading => _loading;

  Map<String, dynamic>? _me;
  Map<String, dynamic>? get meData => _me;

  Future<void> tryBootstrap() async {
    final token = await AppSecureStorage.readToken();
    if (token == null) return;
    try {
      _me = await _service.me();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> doRegister(String fullname, String email, String pwd, String phone) async {
    _loading = true; notifyListeners();
    try {
      await _service.register(fullname: fullname, email: email, password: pwd, phone: phone);
      _me = await _service.me(); // kalau token langsung aktif setelah register
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> doLogin(String email, String pwd) async {
    _loading = true; notifyListeners();
    try {
      await _service.login(email: email, password: pwd);
      _me = await _service.me();
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> doLogout() async {
    await _service.logout();
    _me = null;
    notifyListeners();
  }
}
