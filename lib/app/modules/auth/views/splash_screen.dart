import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('Splash: Chamando checkAuth...');
        context.read<AuthCubit>().checkAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        // Reage a estados finais de decisão
        return current is AuthAuthenticated || current is AuthUnauthenticated;
      },
      listener: (context, state) {
        debugPrint('Splash: Novo estado recebido: \$state');
        
        // ✅ SEMPRE navega para HOME. O acesso anônimo é permitido.
        debugPrint('Splash: Navegando para HOME');
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
      },
      child: const Scaffold(
        backgroundColor: Color(0xFF3949AB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, size: 80, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'QuiPede',
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
