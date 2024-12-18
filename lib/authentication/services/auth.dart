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
        await _storage.write(key: 'user_id', value: data['id'].toString());
        await _storage.write(key: 'role', value: data['role']);
    }

    Future<Map<String, String?>> getUserData() async {
        return {
            'username': await _storage.read(key: 'username'),
            'user_id': await _storage.read(key: 'user_id'),
            'role': await _storage.read(key: 'role'),
        };
    }

    Future<bool> isAdmin() async {
        final role = await _storage.read(key: 'role');
        return role == 'ADM';
    }

    Future<void> logout() async {
        await _storage.deleteAll();
    }
}