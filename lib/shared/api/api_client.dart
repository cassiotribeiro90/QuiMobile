import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/token_service.dart';
import '../../app/di/dependencies.dart';
import '../../app_config.dart';
import 'interceptors/auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final TokenService _tokenService;

  ApiClient({TokenService? tokenService})
      : _tokenService = tokenService ?? getIt<TokenService>() {
    
    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    );

    _dio = Dio(options);
    
    _dio.interceptors.add(AuthInterceptor(_tokenService, _dio));
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true, 
        requestBody: true,
        requestHeader: true,
      ));
    }
  }
  
  Future<Response> post(String path, {dynamic data, bool requiresAuth = true}) => 
      _dio.post(path, data: data, options: Options(extra: {'requiresAuth': requiresAuth}));
      
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters, 
    bool requiresAuth = true
  }) => _dio.get(
    path, 
    queryParameters: queryParameters,
    options: Options(extra: {'requiresAuth': requiresAuth})
  );
      
  Future<Response> put(String path, {dynamic data, bool requiresAuth = true}) => 
      _dio.put(path, data: data, options: Options(extra: {'requiresAuth': requiresAuth}));
      
  Future<Response> delete(String path, {bool requiresAuth = true}) => 
      _dio.delete(path, options: Options(extra: {'requiresAuth': requiresAuth}));

  Dio get dio => _dio;
}
