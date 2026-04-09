import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/modules/auth/bloc/auth_cubit.dart';
import '../../../app/routes/app_routes.dart';
import '../../services/token_service.dart';

class RefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenService _tokenService;
  final GlobalKey<NavigatorState> _navigatorKey;

  final Set<String> _refreshAttempts = {};

  RefreshInterceptor({
    required Dio dio,
    required TokenService tokenService,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _dio = dio,
        _tokenService = tokenService,
        _navigatorKey = navigatorKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final headers = _tokenService.getAuthHeader();
      if (headers.isNotEmpty) {
        options.headers.addAll(headers);
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 1. Verifica se a requisição requer autenticação
    final bool requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;
    
    // ✅ Se for endpoint público (requiresAuth: false) e der erro (401 ou qualquer outro),
    // apenas repassamos o erro sem tentar refresh ou redirecionar.
    if (!requiresAuth) {
      debugPrint('ℹ️ [RefreshInterceptor] Erro em endpoint público (${err.requestOptions.path}), ignorando...');
      handler.next(err);
      return;
    }

    // 2. Bloqueia refresh em endpoints de autenticação
    if (err.requestOptions.path.contains('/login') ||
        err.requestOptions.path.contains('/refresh')) {
      handler.next(err);
      return;
    }

    // 3. Se não for 401, passa adiante
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // 4. Evita loop infinito
    final requestKey = '${err.requestOptions.path}:${err.requestOptions.method}';
    if (_refreshAttempts.contains(requestKey)) {
      _refreshAttempts.remove(requestKey);
      _redirectToLogin();
      handler.next(err);
      return;
    }

    _refreshAttempts.add(requestKey);

    try {
      final hasRefreshToken = _tokenService.getRefreshToken() != null;
      if (!hasRefreshToken) {
        _refreshAttempts.remove(requestKey);
        _redirectToLogin();
        handler.next(err);
        return;
      }

      final success = await _tokenService.refreshToken(_dio);

      if (success) {
        final newHeaders = _tokenService.getAuthHeader();
        final newRequest = err.requestOptions;
        newRequest.headers.addAll(newHeaders);

        final response = await _dio.fetch(newRequest);
        _refreshAttempts.remove(requestKey);
        handler.resolve(response);
      } else {
        _refreshAttempts.remove(requestKey);
        _redirectToLogin();
        handler.next(err);
      }
    } catch (e) {
      _refreshAttempts.remove(requestKey);
      _redirectToLogin();
      handler.next(err);
    }
  }

  void _redirectToLogin() {
    _tokenService.clearTokens();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator != null) {
        final context = _navigatorKey.currentContext;
        if (context != null) {
          try {
            context.read<AuthCubit>().logout();
          } catch (_) {}
        }

        navigator.pushNamedAndRemoveUntil(
          Routes.LOGIN,
          (route) => false,
        );

        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão expirada. Faça login novamente.', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }
}
