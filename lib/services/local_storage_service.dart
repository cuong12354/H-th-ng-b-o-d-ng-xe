import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _serverUrlKey = 'server_base_url';

  // Singleton
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs?.remove(_tokenKey);
  }

  Future<void> saveServerUrl(String url) async {
    await _prefs?.setString(_serverUrlKey, url.trim());
  }

  String? getServerUrl() {
    return _prefs?.getString(_serverUrlKey);
  }

  Future<void> removeServerUrl() async {
    await _prefs?.remove(_serverUrlKey);
  }
}
