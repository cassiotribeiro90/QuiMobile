import 'package:flutter/foundation.dart';

class AppConfig {
  static const String LOGIN = 'app/auth/login';
  static const String REFRESH_TOKEN = 'app/auth/refresh-token';

  static String get baseUrl {
    // Variável de ambiente sobrescreve tudo
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;
    
    // Web
    if (kIsWeb) return 'http://localhost:8001/api/';
    
    // Android Emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Pode ser configurado manualmente para dispositivos físicos
      const deviceIp = String.fromEnvironment('DEVICE_IP');
      if (deviceIp.isNotEmpty) return 'http://$deviceIp:8001/api/';
      return 'http://10.0.2.2:8001/api/';
    }
    
    // Desktop (Windows, macOS, Linux) e iOS Simulator
    return 'http://localhost:8001/api/';
  }
}
