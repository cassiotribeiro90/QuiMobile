import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SharedPreferences _prefs;

  AuthCubit(this._prefs) : super(AuthInitial());

  Future<void> checkAuth() async {
    // Emitimos Loading em vez de Initial para garantir que a UI perceba a intenção de processamento
    emit(AuthLoading());
    
    try {
      // Removido o Future.delayed que estava travando o app
      final token = _prefs.getString('access_token');
      
      if (token != null && token.isNotEmpty) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Caso ocorra erro na leitura do SharedPreferences
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login() async {
    emit(AuthLoading());
    const token = 'mock_token_quipede';
    await _prefs.setString('access_token', token);
    emit(AuthAuthenticated());
  }

  Future<void> logout() async {
    await _prefs.remove('access_token');
    emit(AuthUnauthenticated());
  }
}
