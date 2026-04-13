import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../home/bloc/localizacao_cubit.dart';
import '../../home/bloc/localizacao_state.dart';
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
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // 1. Verificar autenticação
    final authCubit = context.read<AuthCubit>();
    await authCubit.checkAuthStatus();
    
    // 2. Solicitar permissão de localização e obter posição
    final localizacaoCubit = context.read<LocalizacaoCubit>();
    Position? posicao;
    
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        try {
          posicao = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          );
          localizacaoCubit.atualizarPosicao(posicao);
        } catch (_) {}
      }
    }
    
    if (posicao == null) {
      await localizacaoCubit.carregarLocalizacaoDoEnderecoPadrao();
    }

    // 3. Determinar rota inicial e navegar
    if (mounted) {
      final isAuthenticated = authCubit.state is AuthAuthenticated;
      final hasLocation = localizacaoCubit.state is LocalizacaoCarregada;

      String initialRoute;
      if (!isAuthenticated) {
        initialRoute = Routes.login;
      } else if (!hasLocation) {
        // Se desejar ir para endereços quando não tiver localização, use Routes.enderecos (verifique se existe)
        initialRoute = Routes.home; 
      } else {
        initialRoute = Routes.home;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(initialRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF57C00), // Laranja principal
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
    );
  }
}
