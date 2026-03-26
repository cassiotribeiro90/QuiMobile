import 'package:equatable/equatable.dart';
import '../models/loja.dart';

abstract class LojasState extends Equatable {
  const LojasState();
  @override List<Object?> get props => [];
}

class LojasInitial extends LojasState {}

class LojasLoading extends LojasState {}

class LojasLoaded extends LojasState {
  final List<Loja> lojas;
  final List<Loja> lojasFiltradas;
  final List<String> categoriasDisponiveis;
  final List<String> categoriasSelecionadas;
  final String? ordenacaoAtual;
  final Map<String, dynamic>? pagination;

  const LojasLoaded({
    required this.lojas,
    required this.lojasFiltradas,
    this.categoriasDisponiveis = const [],
    this.categoriasSelecionadas = const [],
    this.ordenacaoAtual,
    this.pagination,
  });

  // Getters para compatibilidade
  List<Loja> get allLojas => lojas;
  List<Loja> get filteredLojas => lojasFiltradas;
  List<String> get availableCategories => categoriasDisponiveis;
  List<String> get selectedCategories => categoriasSelecionadas;

  @override
  List<Object?> get props => [lojas, lojasFiltradas, categoriasDisponiveis, categoriasSelecionadas, ordenacaoAtual, pagination];
}

class LojasError extends LojasState {
  final String message;
  const LojasError(this.message);
  @override List<Object?> get props => [message];
}

class LojaOperationSuccess extends LojasState {
  final String message;
  const LojaOperationSuccess(this.message);
  @override List<Object?> get props => [message];
}

class LojaOperationLoading extends LojasState {}
