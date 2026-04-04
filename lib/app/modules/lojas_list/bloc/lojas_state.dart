import 'package:equatable/equatable.dart';
import '../models/loja.dart';
import '../models/filter_option_model.dart';
import '../../loja_home/models/pagination_model.dart';

abstract class LojasState extends Equatable {
  const LojasState();
  @override
  List<Object?> get props => [];
}

class LojasInitial extends LojasState {}
class LojasLoading extends LojasState {}

class LojasLoaded extends LojasState {
  final List<Loja> lojas;
  final List<Loja> lojasFiltradas;
  final List<FilterOptionModel> categorias;
  final String? categoriaSelecionada;
  final String? ordenacaoAtual;
  final String? searchQuery;
  final PaginationModel pagination;
  final bool isLoadingMore;

  const LojasLoaded({
    required this.lojas,
    required this.lojasFiltradas,
    required this.categorias,
    this.categoriaSelecionada,
    this.ordenacaoAtual,
    this.searchQuery,
    required this.pagination,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        lojas,
        lojasFiltradas,
        categorias,
        categoriaSelecionada,
        ordenacaoAtual,
        searchQuery,
        pagination,
        isLoadingMore,
      ];

  LojasLoaded copyWith({
    List<Loja>? lojas,
    List<Loja>? lojasFiltradas,
    List<FilterOptionModel>? categorias,
    String? categoriaSelecionada,
    String? ordenacaoAtual,
    String? searchQuery,
    PaginationModel? pagination,
    bool? isLoadingMore,
  }) {
    return LojasLoaded(
      lojas: lojas ?? this.lojas,
      lojasFiltradas: lojasFiltradas ?? this.lojasFiltradas,
      categorias: categorias ?? this.categorias,
      categoriaSelecionada: categoriaSelecionada ?? this.categoriaSelecionada,
      ordenacaoAtual: ordenacaoAtual ?? this.ordenacaoAtual,
      searchQuery: searchQuery ?? this.searchQuery,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class LojasError extends LojasState {
  final String message;
  const LojasError(this.message);
  @override
  List<Object?> get props => [message];
}
