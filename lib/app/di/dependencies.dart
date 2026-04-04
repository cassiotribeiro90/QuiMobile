import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/loja_home/repository/loja_repository.dart';
import '../modules/lojas_list/repository/loja_repository.dart';
import '../modules/lojas_list/repository/loja_repository_impl.dart';
import '../modules/home/bloc/address_cubit.dart';
import '../modules/home/bloc/home_cubit.dart';
import '../modules/lojas_list/bloc/lojas_cubit.dart';
import '../modules/auth/bloc/auth_cubit.dart';
import '../theme/theme_cubit.dart';
import '../../shared/api/api_client.dart';
import '../../shared/services/token_service.dart';
import '../modules/loja_home/bloc/loja_home_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Services
  getIt.registerLazySingleton<TokenService>(() => TokenService(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(tokenService: getIt<TokenService>()));

  // Repositories
  getIt.registerLazySingleton<LojaRepository>(() => LojaRepositoryImpl(getIt<ApiClient>()));
  getIt.registerLazySingleton<LojaHomeRepository>(() => LojaHomeRepository(getIt<ApiClient>()));

  // Cubits
  getIt.registerSingleton<ThemeCubit>(ThemeCubit(getIt<SharedPreferences>()));
  getIt.registerSingleton<AuthCubit>(AuthCubit(getIt<ApiClient>(), getIt<TokenService>()));

  getIt.registerFactory(() => AddressCubit());
  getIt.registerFactory(() => HomeCubit());
  getIt.registerFactory(() => LojasCubit(getIt<LojaRepository>()));
  
  // Cubit de Loja Home (Único Cubit do módulo)
  getIt.registerFactoryParam<LojaHomeCubit, int, void>(
    (lojaId, _) => LojaHomeCubit(getIt<LojaHomeRepository>(), lojaId),
  );
}
