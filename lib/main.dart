import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qui/app/di/dependencies.dart';
import 'package:qui/app/modules/auth/bloc/auth_cubit.dart';
import 'package:qui/app/modules/home/bloc/address_cubit.dart';
import 'package:qui/app/modules/lojas/bloc/lojas_cubit.dart';
import 'package:qui/app/routes/app_router.dart';
import 'package:qui/app/routes/app_routes.dart';
import 'package:qui/app/core/theme/app_theme.dart';
import 'package:qui/app/theme/theme_cubit.dart';
import 'package:qui/shared/auth/auth_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const QuiPedeApp());
}

class QuiPedeApp extends StatelessWidget {
  const QuiPedeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<AddressCubit>(create: (_) => getIt<AddressCubit>()),
        BlocProvider<LojasCubit>(create: (_) => getIt<LojasCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'QuiPede',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: themeState.themeMode,
            initialRoute: Routes.SPLASH,
            onGenerateRoute: AppRouter.onGenerateRoute,
            navigatorObservers: [AuthObserver()],
            builder: (context, child) {
              return child!;
            },
          );
        },
      ),
    );
  }
}
