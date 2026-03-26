import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/services/token_service.dart';
import '../modules/home/bloc/home_cubit.dart';
import '../modules/lojas/bloc/lojas_cubit.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../modules/loja_home/bloc/loja_home_cubit.dart';
import '../modules/loja_home/repositories/loja_repository.dart';
import '../modules/loja_home/repositories/produto_repository.dart';
import '../theme/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Services
  getIt.registerLazySingleton<TokenService>(() => TokenService(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(tokenService: getIt<TokenService>()));

  // Repositories
  getIt.registerLazySingleton<ILojaRepository>(() => LojaRepositoryMock());
  getIt.registerLazySingleton<IProdutoRepository>(() => ProdutoRepositoryMock());

  // Cubits (padrão quiGestor: pasta bloc)
  getIt.registerSingleton<ThemeCubit>(ThemeCubit(getIt<SharedPreferences>()));
  getIt.registerSingleton<AuthCubit>(AuthCubit(getIt<ApiClient>(), getIt<TokenService>()));
  
  getIt.registerFactory(() => HomeCubit());
  getIt.registerFactory(() => LojasCubit(getIt<ApiClient>()));
  getIt.registerFactoryParam<LojaHomeCubit, int, void>(
    (lojaId, _) => LojaHomeCubit(
      getIt<ILojaRepository>(), 
      getIt<IProdutoRepository>(), 
      lojaId
    ),
  );
}
