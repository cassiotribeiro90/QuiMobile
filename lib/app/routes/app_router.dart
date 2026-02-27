import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qui/app/di/dependencies.dart';
import 'package:qui/app/modules/loja_home/cubit/loja_home_cubit.dart';
import 'package:qui/app/modules/loja_home/views/loja_home_view.dart';
import '../modules/home/cubit/home_cubit.dart';
import '../modules/home/views/home_view.dart';
import '../modules/loja_avaliacoes/cubit/loja_avaliacoes_cubit.dart';
import '../modules/loja_avaliacoes/views/loja_avaliacoes_view.dart';
import '../modules/splash/cubit/splash_cubit.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.SPLASH:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<SplashCubit>(),
            child: const SplashView(),
          ),
        );
      case Routes.HOME:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<HomeCubit>(),
            child: const HomeView(),
          ),
        );
      case Routes.LOJA_AVALIACOES:
        final lojaId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<LojaAvaliacoesCubit>(param1: lojaId),
            child: const LojaAvaliacoesView(),
          ),
        );
      case Routes.LOJA_HOME:
        final lojaId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<LojaHomeCubit>(param1: lojaId),
            child: const LojaHomeView(), // CORRIGIDO: Não precisa mais passar o ID
          ),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}
