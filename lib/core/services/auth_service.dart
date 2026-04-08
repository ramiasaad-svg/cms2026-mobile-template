import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

class AuthService {
  final ApiClient apiClient;
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'cms2026_token';
  static const _userKey = 'cms2026_user';

  String? _token;
  Map<String, dynamic>? _currentUser;

  AuthService(this.apiClient);

  bool get isLoggedIn => _token != null;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get userName => _currentUser?['userName'];

  Future<void> init() async {
    _token = await _storage.read(key: _tokenKey);
    if (_token != null) {
      apiClient.setToken(_token);
      await _loadCurrentUser();
    }
  }

  Future<bool> login(String userName, String password) async {
    try {
      final res = await apiClient.post('/auth/login', data: {'userName': userName, 'password': password});
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        _token = data['token'] as String?;
        _currentUser = data;
        if (_token != null) {
          apiClient.setToken(_token);
          await _storage.write(key: _tokenKey, value: _token);
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    apiClient.setToken(null);
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<void> _loadCurrentUser() async {
    try {
      final res = await apiClient.get('/auth/me');
      if (res.success && res.data != null) {
        _currentUser = res.data as Map<String, dynamic>;
      } else {
        await logout();
      }
    } catch (_) {
      // Token may be expired
      await logout();
    }
  }
}
