import 'package:get_it/get_it.dart';
import 'package:qui/app/repository/loja_repository.dart';
import 'package:qui/app/repository/loja_repository_impl.dart';
import 'package:qui/app/modules/home/bloc/address_cubit.dart';
import 'package:qui/app/modules/home/bloc/home_cubit.dart';
import 'package:qui/app/modules/lojas/bloc/lojas_cubit.dart';
import 'package:qui/app/modules/auth/bloc/auth_cubit.dart';
import 'package:qui/app/theme/theme_cubit.dart';
import 'package:qui/shared/api/api_client.dart';
import 'package:qui/shared/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Services
  getIt.registerLazySingleton<TokenService>(() => TokenService(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(tokenService: getIt<TokenService>()));

  // Repositories
  getIt.registerLazySingleton<LojaRepository>(() => LojaRepositoryImpl(getIt<ApiClient>()));

  // Cubits
  getIt.registerSingleton<ThemeCubit>(ThemeCubit(getIt<SharedPreferences>()));
  getIt.registerSingleton<AuthCubit>(AuthCubit(getIt<ApiClient>(), getIt<TokenService>()));

  getIt.registerFactory(() => AddressCubit());
  getIt.registerFactory(() => HomeCubit());
  getIt.registerFactory(() => LojasCubit(getIt<LojaRepository>()));
}
