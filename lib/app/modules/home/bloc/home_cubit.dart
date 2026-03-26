import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeTabChanged(0));

  void changeTab(int index) {
    emit(HomeTabChanged(index));
  }
}
