import 'package:flutter/material.dart';
import '../../app/di/dependencies.dart';
import '../services/token_service.dart';

class AuthObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkTokenExpiration(route.navigator?.context);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _checkTokenExpiration(newRoute?.navigator?.context);
  }

  void _checkTokenExpiration(BuildContext? context) {
    if (context == null) return;
    
    final tokenService = getIt<TokenService>();
    
    // ✅ Se token expirou, apenas limpa silenciosamente. 
    // O usuário poderá continuar navegando mas precisará logar para ações protegidas.
    if (tokenService.isTokenExpired() && tokenService.isLoggedIn()) {
      debugPrint('⚠️ [AuthObserver] Token expirado, limpando silenciosamente...');
      tokenService.clearTokens();
    }
  }
}
