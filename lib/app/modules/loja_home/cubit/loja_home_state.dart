import 'package:equatable/equatable.dart';
import '../../../models/loja_model.dart';
import '../../../models/produto_model.dart';

abstract class LojaHomeState extends Equatable {
  const LojaHomeState();

  @override
  List<Object> get props => [];
}

class LojaHomeInitial extends LojaHomeState {}

class LojaHomeLoading extends LojaHomeState {}

class LojaHomeLoaded extends LojaHomeState {
  final Loja loja;
  final List<Produto> produtos;
  final Map<String, List<Produto>> produtosPorCategoria;

  const LojaHomeLoaded(this.loja, this.produtos, this.produtosPorCategoria);

  @override
  List<Object> get props => [loja, produtos, produtosPorCategoria];
}

class LojaHomeError extends LojaHomeState {
  final String message;

  const LojaHomeError(this.message);

  @override
  List<Object> get props => [message];
}
