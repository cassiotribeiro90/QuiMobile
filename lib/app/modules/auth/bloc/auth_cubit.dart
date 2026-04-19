import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config.dart';
import '../../../../shared/api/api_client.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../models/auth_response_model.dart';
import '../models/usuario_model.dart';
import '../services/social_auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  final SocialAuthService _socialAuthService;
  final LocalizacaoCubit _localizacaoCubit;
  bool _isProcessing = false;
  UsuarioModel? _usuario;

  AuthCubit(this._apiClient, this._localizacaoCubit) 
      : _socialAuthService = SocialAuthService(_apiClient),
        super(AuthInitial());

  UsuarioModel? get usuario => _usuario;

  Future<void> checkAuthStatus() async {
    if (_isProcessing) return;
    _isProcessing = true;

    debugPrint('🔐 [AuthCubit] Iniciando checkAuthStatus...');
    emit(AuthChecking());
    
    try {
      final String? token = _apiClient.tokenService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        emit(AuthUnauthenticated());
        return;
      }
      
      if (_apiClient.tokenService.isTokenExpired()) {
        debugPrint('🔐 [AuthCubit] Token expirado localmente, tentando refresh...');
        final refreshSuccess = await _apiClient.tokenService.refreshToken(_apiClient.dio);
        
        if (!refreshSuccess) {
          debugPrint('🔐 [AuthCubit] Falha no refresh token.');
          await _apiClient.tokenService.clearTokens();
          emit(AuthUnauthenticated());
          return;
        }
      }

      debugPrint('🔐 [AuthCubit] Validando token br o backend (/app/auth/me)...');
      try {
        final response = await _apiClient.get('app/auth/me', requiresAuth: true);
        
        if (response.statusCode == 200 && response.data['success'] == true) {
          final data = response.data['data'];
          
          debugPrint('🔄 [AuthCubit] INICIANDO MAPEAMENTO para AuthResponse');
          final authResponse = AuthResponse.fromJson(data);
          debugPrint('✅ [AuthCubit] MAPEAMENTO CONCLUÍDO');
          
          _usuario = authResponse.user;
          
          if (authResponse.endereco != null) {
            _localizacaoCubit.definirEnderecoCompleto(authResponse.endereco!, origem: 'endereco_padrao');
          }

          final currentToken = _apiClient.tokenService.getAccessToken()!;
          emit(AuthAuthenticated(accessToken: currentToken));
        } else {
          await _apiClient.tokenService.clearTokens();
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 401) {
          await _apiClient.tokenService.clearTokens();
          emit(AuthUnauthenticated());
        } else {
          final currentToken = _apiClient.tokenService.getAccessToken()!;
          emit(AuthAuthenticated(accessToken: currentToken));
        }
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> login(String email, String senha) async {
    if (_isProcessing) return;
    _isProcessing = true;

    emit(AuthLoading());

    try {
      debugPrint('🚀 [AuthCubit] Iniciando login: $email');
      
      final response = await _apiClient.post(
        AppConfig.LOGIN, 
        data: {'email': email, 'senha': senha},
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        
        debugPrint('🔄 [AuthCubit] INICIANDO MAPEAMENTO para AuthResponse');
        final authResponse = AuthResponse.fromJson(data);
        debugPrint('✅ [AuthCubit] MAPEAMENTO CONCLUÍDO');
        
        _usuario = authResponse.user;
        
        if (authResponse.endereco != null) {
          _localizacaoCubit.definirEnderecoCompleto(authResponse.endereco!, origem: 'endereco_padrao');
        }

        await _saveAuthResponse(authResponse);
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro no login'));
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro de conexão';
      emit(AuthError(message));
    } catch (e) {
      emit(const AuthError('Erro inesperado'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> validarEtapa1(Map<String, dynamic> dados) async {
    if (_isProcessing) return false;
    _isProcessing = true;

    emit(AuthLoading());

    try {
      final response = await _apiClient.post(
        AppConfig.VALIDAR_ETAPA1,
        data: dados,
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        emit(AuthInitial()); // Reset loading state
        return true;
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro na validação'));
        return false;
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro de conexão';
      emit(AuthError(message));
      return false;
    } catch (e) {
      emit(const AuthError('Erro inesperado na validação'));
      return false;
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> cadastrar(Map<String, dynamic> dados) async {
    if (_isProcessing) return;
    _isProcessing = true;

    emit(AuthLoading());

    try {
      final response = await _apiClient.post(
        AppConfig.CADASTRAR,
        data: dados,
        requiresAuth: false,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        
        debugPrint('🔄 [AuthCubit] INICIANDO MAPEAMENTO para AuthResponse');
        final authResponse = AuthResponse.fromJson(data);
        debugPrint('✅ [AuthCubit] MAPEAMENTO CONCLUÍDO');

        _usuario = authResponse.user;

        if (authResponse.endereco != null) {
          _localizacaoCubit.definirEnderecoCompleto(authResponse.endereco!, origem: 'endereco_padrao');
        }

        await _saveAuthResponse(authResponse);
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro no cadastro'));
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro de conexão';
      emit(AuthError(message));
    } catch (e) {
      emit(const AuthError('Erro inesperado no cadastro'));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> socialLogin(String provider) async {
    if (_isProcessing) return;
    _isProcessing = true;

    emit(AuthLoading());
    try {
      AuthResponse response;
      switch (provider) {
        case 'google':
          response = await _socialAuthService.signInWithGoogle();
          break;
        case 'facebook':
          response = await _socialAuthService.signInWithFacebook();
          break;
        case 'apple':
          response = await _socialAuthService.signInWithApple();
          break;
        default:
          throw Exception('Provedor não suportado');
      }

      _usuario = response.user;

      if (response.endereco != null) {
        _localizacaoCubit.definirEnderecoCompleto(response.endereco!, origem: 'endereco_padrao');
      }

      await _saveAuthResponse(response);
    } on SocialAuthCanceledException {
      emit(AuthUnauthenticated()); 
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _saveAuthResponse(AuthResponse response) async {
    await _apiClient.tokenService.saveTokens(
      response.accessToken, 
      response.refreshToken, 
      expiresIn: response.expiresIn
    );
    emit(AuthAuthenticated(accessToken: response.accessToken));
  }

  Future<void> logout() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      await _apiClient.post('app/auth/logout', requiresAuth: false);
    } catch (e) {
      // ignore
    } finally {
      _usuario = null;
      await _apiClient.tokenService.clearTokens();
      await _localizacaoCubit.limparLocalizacao();
      emit(AuthUnauthenticated());
      _isProcessing = false;
    }
  }

  Future<void> checkAuth() => checkAuthStatus();
}
