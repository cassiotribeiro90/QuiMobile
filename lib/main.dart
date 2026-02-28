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
      // Builder para layout responsivo global
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Se a tela for larga (web), centraliza o conteúdo.
            if (constraints.maxWidth > 800) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  // Adiciona uma borda sutil para melhor visualização
                  child: Container(
                     decoration: BoxDecoration(
                       border: Border.symmetric(vertical: BorderSide(color: Colors.grey[200]!)),
                     ),
                    child: child,
                  ),
                ),
              );
            }
            // No mobile, retorna o conteúdo diretamente.
            return child!;
          },
        );
      },
    );
  }
}
