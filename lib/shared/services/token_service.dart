import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  
  static const String ACCESS_TOKEN_KEY = 'access_token';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const String TOKEN_EXPIRES_KEY = 'token_expires_at';
  static const String BASE_URL_KEY = 'base_url';

  late final SharedPreferences _prefs;

  TokenService._internal();

  static Future<void> initialize() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveTokens(
    String accessToken, 
    String? refreshToken, {
    int expiresIn = 900,
  }) async {
    await _prefs.setString(ACCESS_TOKEN_KEY, accessToken);
    if (refreshToken != null) {
      await _prefs.setString(REFRESH_TOKEN_KEY, refreshToken);
    }
    final expiresAt = DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
    await _prefs.setString(TOKEN_EXPIRES_KEY, expiresAt.toString());
  }

  String? getAccessToken() => _prefs.getString(ACCESS_TOKEN_KEY);
  String? getRefreshToken() => _prefs.getString(REFRESH_TOKEN_KEY);

  Map<String, String> getAuthHeader() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty 
        ? {'Authorization': 'Bearer $token'} 
        : {};
  }

  bool isTokenExpired() {
    final expiresAtStr = _prefs.getString(TOKEN_EXPIRES_KEY);
    if (expiresAtStr == null) return true;
    final expiresAt = int.tryParse(expiresAtStr) ?? 0;
    // Margem de segurança de 30 segundos
    return DateTime.now().millisecondsSinceEpoch > (expiresAt - 30000);
  }

  bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty && !isTokenExpired();
  }

  Future<void> clearTokens() async {
    await _prefs.remove(ACCESS_TOKEN_KEY);
    await _prefs.remove(REFRESH_TOKEN_KEY);
    await _prefs.remove(TOKEN_EXPIRES_KEY);
  }

  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(BASE_URL_KEY, url);
  }

  String? getBaseUrl() => _prefs.getString(BASE_URL_KEY);

  Future<bool> refreshToken(Dio dio) async {
    try {
      final refreshToken = getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final baseUrl = getBaseUrl() ?? dio.options.baseUrl;
      
      final tempDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await tempDio.post(
        '/app/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['access_token']?.toString() ?? '';
        final newRefreshToken = data['refresh_token']?.toString();
        final expiresIn = data['expires_in'] ?? 900;

        if (newAccessToken.isNotEmpty) {
          await saveTokens(newAccessToken, newRefreshToken, expiresIn: expiresIn);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
