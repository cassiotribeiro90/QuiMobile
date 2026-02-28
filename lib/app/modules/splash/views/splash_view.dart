import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashLoaded) {
            // CORRIGIDO: Substitui a tela atual em vez de empilhar uma nova.
            Navigator.of(context).pushReplacementNamed(Routes.HOME);
          }
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
