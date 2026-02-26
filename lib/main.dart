import 'package:flutter/material.dart';
import 'app/routes/app_router.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qui Delivery',
      theme: AppTheme.themeData, // <<< APLICANDO O TEMA!
      initialRoute: Routes.SPLASH,
      onGenerateRoute: AppRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false, // Remove o banner de debug
    );
  }
}
