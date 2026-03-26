import 'package:equatable/equatable.dart';
import '../../../models/produto_model.dart';

abstract class ProdutosState extends Equatable {
  const ProdutosState();

  @override
  List<Object?> get props => [];
}

class ProdutosInitial extends ProdutosState {}

class ProdutosLoading extends ProdutosState {}

class ProdutoDetailLoaded extends ProdutosState {
  final Produto produto;

  const ProdutoDetailLoaded(this.produto);

  @override
  List<Object?> get props => [produto];
}

class ProdutosError extends ProdutosState {
  final String message;
  const ProdutosError(this.message);

  @override
  List<Object?> get props => [message];
}
