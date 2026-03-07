import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qui/app/modules/loja_home/repositories/loja_repository.dart';
import 'package:qui/app/modules/loja_home/repositories/produto_repository.dart';

import '../modules/home/cubit/home_cubit.dart';
import '../modules/loja_avaliacoes/cubit/loja_avaliacoes_cubit.dart';
import '../modules/loja_home/cubit/loja_home_cubit.dart';
import '../modules/lojas/cubit/lojas_cubit.dart';
import '../modules/splash/cubit/splash_cubit.dart';

import '../../shared/api/api_service.dart';
import '../../features/auth/bloc/auth_cubit.dart';
import '../../features/loja/bloc/loja_cubit.dart';
import '../theme/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Serviços Externos
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Theme Cubit
  getIt.registerSingleton<ThemeCubit>(ThemeCubit(prefs));
  
  // API Service
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repositórios
  getIt.registerLazySingleton<ILojaRepository>(() => LojaRepositoryMock());
  getIt.registerLazySingleton<IProdutoRepository>(() => ProdutoRepositoryMock());

  // Cubits
  getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(getIt<SharedPreferences>()));
  getIt.registerFactory(() => LojaCubit(getIt<ApiService>()));

  // Cubits (Existentes)
  getIt.registerFactory(() => SplashCubit());
  getIt.registerFactory(() => HomeCubit());
  getIt.registerFactory(() => LojasCubit());

  getIt.registerFactoryParam<LojaHomeCubit, int, void>(
    (lojaId, _) => LojaHomeCubit(
      getIt<ILojaRepository>(),
      getIt<IProdutoRepository>(),
      lojaId,
    )..fetchLojaDetails(),
  );

  getIt.registerFactoryParam<LojaAvaliacoesCubit, int, void>(
    (lojaId, _) => LojaAvaliacoesCubit(lojaId)..loadAvaliacoes(),
  );
}
