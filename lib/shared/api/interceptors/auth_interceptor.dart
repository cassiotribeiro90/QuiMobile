import 'package:dio/dio.dart';
import '../../../app/di/dependencies.dart';
import '../../../app/modules/auth/bloc/auth_cubit.dart';
import '../../services/token_service.dart';

class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;
  final List<_PendingRequest> _pendingRequests = [];
  bool _isRefreshing = false;

  AuthInterceptor(this._tokenService, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool requiresAuth = options.extra['requiresAuth'] ?? true;
    
    if (requiresAuth) {
      final token = _tokenService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final bool requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;

    if (err.response?.statusCode != 401 || !requiresAuth) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add(_PendingRequest(err, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final success = await _refreshToken();
      
      if (success) {
        final newToken = _tokenService.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);

        await _retryFailedRequests();
      } else {
        _logout();
        handler.next(err);
      }
    } catch (e) {
      _logout();
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _tokenService.getRefreshToken();
      if (refreshToken == null) return false;

      // TODO: Implementar chamada real de refresh token se necessário
      // final response = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
      // if (response.statusCode == 200) {
      //   await _tokenService.saveTokens(response.data['access_token'], response.data['refresh_token']);
      //   return true;
      // }
      
      return false; 
    } catch (e) {
      return false;
    }
  }

  Future<void> _retryFailedRequests() async {
    final token = _tokenService.getAccessToken();

    for (var request in _pendingRequests) {
      request.err.requestOptions.headers['Authorization'] = 'Bearer $token';
      try {
        final response = await _dio.fetch(request.err.requestOptions);
        request.handler.resolve(response);
      } catch (e) {
        request.handler.reject(DioException(requestOptions: request.err.requestOptions));
      }
    }
  }

  void _logout() {
    getIt<AuthCubit>().logout();
  }
}

class _PendingRequest {
  final DioException err;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.err, this.handler);
}
