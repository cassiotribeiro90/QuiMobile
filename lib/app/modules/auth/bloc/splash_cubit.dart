import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> init() async {
    emit(SplashLoading());
    await Future.delayed(const Duration(milliseconds: 1500));
    emit(SplashLoaded());
  }
}
