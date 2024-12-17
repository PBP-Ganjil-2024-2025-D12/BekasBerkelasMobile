import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> storeUserLoggedIn(Map<String, dynamic> data) async {
    await _storage.write(key: 'username', value: data['username']);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getUserLoggedIn() async {
    return await _storage.read(key: 'username');
  }
}
