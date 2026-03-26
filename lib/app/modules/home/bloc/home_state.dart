part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeTabChanged extends HomeState {
  final int selectedIndex;

  const HomeTabChanged(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
