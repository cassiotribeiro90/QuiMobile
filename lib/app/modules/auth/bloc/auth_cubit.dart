import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/services/token_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  AuthCubit(this._apiClient, this._tokenService) : super(AuthInitial());

  Future<void> login(String email, String senha) async {
    emit(AuthLoading());
    try {
      final response = await _apiClient.post(
        '/app/auth/login',
        data: {'email': email, 'senha': senha},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        await _tokenService.saveTokens(
          data['access_token'],
          data['refresh_token'],
        );
        emit(AuthSuccess(token: data['access_token']));
      } else {
        emit(AuthError(response.data['message'] ?? 'Erro ao realizar login'));
      }
    } catch (e) {
      emit(const AuthError('Erro de conexão com o servidor'));
    }
  }

  Future<void> logout() async {
    await _tokenService.clearTokens();
    emit(AuthUnauthenticated());
  }

  Future<void> checkAuth() async {
    final token = _tokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(token: token));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
