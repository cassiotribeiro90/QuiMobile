import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/dependencies.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/carrinho/views/carrinho_page.dart';
import '../modules/home/bloc/home_cubit.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/loja_home/views/loja_detalhe_page.dart';
import '../modules/lojas_list/bloc/lojas_cubit.dart';
import '../modules/perfil/views/pedidos_view.dart';
import '../modules/perfil/views/perfil_view.dart';
import '../modules/perfil/views/enderecos_view.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.SPLASH:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const SplashScreen(),
          ),
        );
      
      case Routes.LOGIN:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const LoginScreen(),
          ),
        );

      case Routes.HOME:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<HomeCubit>()),
              BlocProvider.value(value: getIt<LojasCubit>()),
            ],
            child: const HomeScreen(),
          ),
        );

      case Routes.LOJA_HOME:
        final lojaId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => LojaDetalhePage(lojaId: lojaId),
        );

      case Routes.PERFIL:
        return MaterialPageRoute(builder: (_) => const PerfilView());
      
      case Routes.ENDERECOS:
        return MaterialPageRoute(builder: (_) => const EnderecosView());

      case Routes.PEDIDOS:
        return MaterialPageRoute(builder: (_) => const PedidosView());

      case Routes.CARRINHO:
        return MaterialPageRoute(builder: (_) => const CarrinhoPage());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Rota não encontrada')),
      ),
    );
  }
}
