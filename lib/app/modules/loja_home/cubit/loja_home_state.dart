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
  final List<Produto> allProdutos;
  final List<Produto> filteredProdutos;
  final Map<String, List<Produto>> produtosPorCategoria;
  final Set<String> availableCategories;
  final Set<String> selectedCategories;
  final String searchQuery;

  const LojaHomeLoaded({
    required this.loja,
    required this.allProdutos,
    required this.filteredProdutos,
    required this.produtosPorCategoria,
    required this.availableCategories,
    required this.selectedCategories,
    required this.searchQuery,
  });

  int get activeFilterCount => selectedCategories.length;

  LojaHomeLoaded copyWith({
    Loja? loja,
    List<Produto>? allProdutos,
    List<Produto>? filteredProdutos,
    Map<String, List<Produto>>? produtosPorCategoria,
    Set<String>? availableCategories,
    Set<String>? selectedCategories,
    String? searchQuery,
  }) {
    return LojaHomeLoaded(
      loja: loja ?? this.loja,
      allProdutos: allProdutos ?? this.allProdutos,
      filteredProdutos: filteredProdutos ?? this.filteredProdutos,
      produtosPorCategoria: produtosPorCategoria ?? this.produtosPorCategoria,
      availableCategories: availableCategories ?? this.availableCategories,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [
        loja,
        allProdutos,
        filteredProdutos,
        produtosPorCategoria,
        availableCategories,
        selectedCategories,
        searchQuery,
      ];
}

class LojaHomeError extends LojaHomeState {
  final String message;

  const LojaHomeError(this.message);

  @override
  List<Object> get props => [message];
}
