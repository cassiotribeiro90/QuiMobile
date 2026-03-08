import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/di/dependencies.dart';
import '../../../app/routes/app_routes.dart';

class AuthObserver extends NavigatorObserver {
  // Semáforo para evitar loops de redirecionamento
  bool _isProcessing = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkToken(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _checkToken(newRoute);
  }

  void _checkToken(Route<dynamic> route) {
    if (_isProcessing) return; // Trava o semáforo
    
    final routeName = route.settings.name;
    final publicRoutes = [Routes.LOGIN, Routes.SPLASH, '/register'];

    if (routeName == null || publicRoutes.contains(routeName)) {
      return;
    }

    final prefs = getIt<SharedPreferences>();
    final token = prefs.getString('access_token');

    if (token == null) {
      _isProcessing = true; // Ativa o semáforo antes de navegar
      
      // Usamos microtask apenas para sair do frame atual do Navigator, sem delay.
      Future.microtask(() {
        if (navigator != null) {
          navigator!.pushNamedAndRemoveUntil(Routes.LOGIN, (route) => false);
        }
        _isProcessing = false; // Libera o semáforo após a navegação
      });
    }
  }
}
