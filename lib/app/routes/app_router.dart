import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qui/app/di/dependencies.dart';
import 'package:qui/app/modules/auth/bloc/auth_cubit.dart';
import 'package:qui/app/modules/auth/views/login_screen.dart';
import 'package:qui/app/modules/home/views/home_screen.dart';
import 'package:qui/app/modules/lojas/bloc/lojas_cubit.dart';
import 'package:qui/app/modules/auth/views/splash_screen.dart';
import 'package:qui/app/modules/perfil/views/perfil_view.dart';
import 'package:qui/app/modules/perfil/views/enderecos_view.dart';
import 'package:qui/app/modules/perfil/views/pedidos_view.dart';
import '../modules/home/bloc/address_cubit.dart';
import '../modules/home/bloc/home_cubit.dart';
import '../modules/loja_home/bloc/loja_home_cubit.dart';
import '../modules/loja_home/views/loja_home_view.dart';
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
            ],
            child: const HomeScreen(),
          ),
        );

      case Routes.LOJA_HOME:
        final lojaId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<LojaHomeCubit>(
            create: (context) => getIt<LojaHomeCubit>(param1: lojaId),
            child: const LojaHomeView(),
          ),
        );

      case Routes.PERFIL:
        return MaterialPageRoute(builder: (_) => const PerfilView());
      
      case Routes.ENDERECOS:
        return MaterialPageRoute(builder: (_) => const EnderecosView());

      case Routes.PEDIDOS:
        return MaterialPageRoute(builder: (_) => const PedidosView());

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
