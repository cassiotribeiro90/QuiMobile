import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config.dart';
import '../../../../shared/api/api_client.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;

  AuthCubit(this._apiClient) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    print('🔐 [AuthCubit] Iniciando checkAuthStatus...');
    emit(AuthChecking());
    
    final String? token = _apiClient.tokenService.getAccessToken();
    print('🔐 [AuthCubit] Token existe? \${token != null}');
    
    if (token == null || token.isEmpty) {
      print('🔐 [AuthCubit] Sem token, emitindo AuthUnauthenticated');
      emit(AuthUnauthenticated());
      return;
    }
    
    if (_apiClient.tokenService.isTokenExpired()) {
      print('🔐 [AuthCubit] Token expirado, tentando refresh...');
      final refreshSuccess = await _apiClient.tokenService.refreshToken(_apiClient.dio);
      
      if (refreshSuccess) {
        final newToken = _apiClient.tokenService.getAccessToken();
        print('🔐 [AuthCubit] Refresh bem-sucedido!');
        emit(AuthAuthenticated(accessToken: newToken!));
      } else {
        print('🔐 [AuthCubit] Refresh falhou, limpando tokens');
        await _apiClient.tokenService.clearTokens();
        emit(AuthUnauthenticated());
      }
    } else {
      print('🔐 [AuthCubit] Token válido, emitindo AuthAuthenticated');
      emit(AuthAuthenticated(accessToken: token));
    }
  }

  Future<void> login(String email, String senha) async {
    print('📱 [LOGIN] Tentando login com email: \$email');
    emit(AuthLoading());

    try {
      final response = await _apiClient.post(
        AppConfig.LOGIN, 
        data: {'email': email, 'senha': senha},
        requiresAuth: false,
      );

      print('📱 [LOGIN] Status code: \${response.statusCode}');
      print('📱 [LOGIN] Dados: \${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final String accessToken = data['access_token']?.toString() ?? '';
        final String? refreshToken = data['refresh_token']?.toString();
        final int expiresIn = data['expires_in'] ?? 7200;
        
        if (accessToken.isNotEmpty) {
          final int tokenLength = accessToken.length;
          final int displayLength = min<int>(20, tokenLength);
          
          print('📱 [LOGIN] Token recebido: \${accessToken.substring(0, displayLength)}...');
          
          await _apiClient.tokenService.saveTokens(
            accessToken, 
            refreshToken, 
            expiresIn: expiresIn
          );
          
          await _apiClient.tokenService.saveBaseUrl(_apiClient.dio.options.baseUrl);
          
          final savedToken = _apiClient.tokenService.getAccessToken();
          print('📱 [LOGIN] Token recuperado após salvar: ${savedToken != null ? 'OK' : 'FALHOU'}');

          emit(AuthAuthenticated(accessToken: accessToken));
        } else {
          print('📱 [LOGIN] Erro: Token não recebido');
          emit(const AuthError('Token não recebido'));
        }
      } 
      else if (response.statusCode == 401 || response.data['success'] == false) {
        final message = response.data['message'] ?? 'Email ou senha inválidos';
        print('📱 [LOGIN] Falha: \$message');
        emit(AuthError(message));
      } 
      else {
        final message = response.data['message'] ?? 'Erro no login';
        print('📱 [LOGIN] Erro inesperado no status code: \${response.statusCode} - \$message');
        emit(AuthError(message));
      }
      
    } on DioException catch (e) {
      print('📱 [LOGIN] DioException: \${e.response?.statusCode} - \${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        final message = e.response?.data['message'] ?? 'Email ou senha inválidos';
        emit(AuthError(message));
      } else {
        emit(const AuthError('Erro de conexão'));
      }
    } catch (e, stacktrace) {
      print('📱 [LOGIN] Exceção: \$e');
      print('📱 [LOGIN] Stacktrace: \$stacktrace');
      emit(const AuthError('Erro inesperado'));
    }
  }

  Future<void> logout() async {
    print('📱 [LOGOUT] Iniciando logout...');
    try {
      await _apiClient.post('app/auth/logout', requiresAuth: true);
    } catch (_) {}
    
    await _apiClient.tokenService.clearTokens();
    emit(AuthUnauthenticated());
  }

  Future<void> checkAuth() => checkAuthStatus();
}
