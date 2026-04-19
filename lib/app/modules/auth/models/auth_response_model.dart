import 'package:flutter/foundation.dart';
import '../../../models/endereco_model.dart';
import 'usuario_model.dart';

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final UsuarioModel user;
  final EnderecoModel? endereco;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.user,
    this.endereco,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔄 [AuthResponse.fromJson] Iniciando parsing');
      
      final data = json['data'] ?? json;
      debugPrint('   - Data keys: ${data.keys.join(', ')}');
      
      if (data['endereco'] != null) {
        debugPrint('🔄 [AuthResponse.fromJson] Iniciando parsing do ENDEREÇO');
        debugPrint('   - Endereco keys: ${data['endereco'].keys.join(', ')}');
      }

      final result = AuthResponse(
        accessToken: data['access_token'] ?? '',
        refreshToken: data['refresh_token'],
        expiresIn: data['expires_in'] ?? 7200,
        user: UsuarioModel.fromJson(data['user'] ?? data['usuario'] ?? data),
        endereco: (data['endereco'] != null) 
            ? EnderecoModel.fromJson(data['endereco']) 
            : null,
      );

      debugPrint('✅ [AuthResponse.fromJson] Parsing concluído');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthResponse.fromJson] ERRO NO PARSING');
      debugPrint('❌ Tipo: ${e.runtimeType}');
      debugPrint('❌ Mensagem: $e');
      debugPrint('❌ JSON recebido: $json');
      debugPrint('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }
}
