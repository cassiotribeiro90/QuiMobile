import 'package:get_it/get_it.dart';
import 'package:qui/app/modules/loja_home/repositories/loja_repository.dart';
import 'package:qui/app/modules/loja_home/repositories/produto_repository.dart';

import '../modules/home/cubit/home_cubit.dart';
import '../modules/loja_avaliacoes/cubit/loja_avaliacoes_cubit.dart';
import '../modules/loja_home/cubit/loja_home_cubit.dart';
import '../modules/lojas/cubit/lojas_cubit.dart';
import '../modules/splash/cubit/splash_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Repositórios
  getIt.registerLazySingleton<ILojaRepository>(() => LojaRepositoryMock());
  getIt.registerLazySingleton<IProdutoRepository>(() => ProdutoRepositoryMock());

  // Cubits
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
