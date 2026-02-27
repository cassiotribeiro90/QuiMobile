import 'package:equatable/equatable.dart';
import '../../../models/loja_model.dart';

abstract class LojaHomeState extends Equatable {
  const LojaHomeState();

  @override
  List<Object> get props => [];
}

class LojaHomeInitial extends LojaHomeState {}

class LojaHomeLoading extends LojaHomeState {}

class LojaHomeLoaded extends LojaHomeState {
  final Loja loja;

  const LojaHomeLoaded(this.loja);

  @override
  List<Object> get props => [loja];
}

class LojaHomeError extends LojaHomeState {
  final String message;

  const LojaHomeError(this.message);

  @override
  List<Object> get props => [message];
}
