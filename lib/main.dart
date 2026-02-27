import 'package:flutter/material.dart';
import 'app/di/dependencies.dart';
import 'app/routes/app_router.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies(); // Inicializa as dependências
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qui Delivery',
      theme: AppTheme.themeData,
      initialRoute: Routes.SPLASH,
      onGenerateRoute: AppRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
