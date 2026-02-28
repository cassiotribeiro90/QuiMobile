import 'package:bloc/bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial()) {
    _init();
  }

  void _init() async {
    // Simula um tempo de carregamento para a splash screen
    await Future.delayed(const Duration(seconds: 2));
    emit(SplashLoaded());
  }
}
