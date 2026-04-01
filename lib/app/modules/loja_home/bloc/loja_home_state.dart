import 'package:equatable/equatable.dart';
import '../../lojas/models/loja.dart';
import '../../../models/produto_model.dart';

abstract class LojaHomeState extends Equatable {
  const LojaHomeState();
  @override
  List<Object?> get props => [];
}

class LojaHomeInitial extends LojaHomeState {}

class LojaHomeLoading extends LojaHomeState {}

class LojaHomeError extends LojaHomeState {
  final String message;
  const LojaHomeError(this.message);
  @override
  List<Object?> get props => [message];
}

class LojaHomeLoaded extends LojaHomeState {
  final Loja loja;
  final List<Produto> produtos;
  final Map<String, List<Produto>> produtosPorCategoria;
  final List<String> selectedCategories;
  final int activeFilterCount;
  final bool hasMore;
  final int currentPage;

  const LojaHomeLoaded({
    required this.loja,
    required this.produtos,
    required this.produtosPorCategoria,
    required this.selectedCategories,
    required this.activeFilterCount,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [
        loja,
        produtos,
        produtosPorCategoria,
        selectedCategories,
        activeFilterCount,
        hasMore,
        currentPage,
      ];

  LojaHomeLoaded copyWith({
    Loja? loja,
    List<Produto>? produtos,
    Map<String, List<Produto>>? produtosPorCategoria,
    List<String>? selectedCategories,
    int? activeFilterCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return LojaHomeLoaded(
      loja: loja ?? this.loja,
      produtos: produtos ?? this.produtos,
      produtosPorCategoria: produtosPorCategoria ?? this.produtosPorCategoria,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      activeFilterCount: activeFilterCount ?? this.activeFilterCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class LojaHomeLoadingMore extends LojaHomeLoaded {
  const LojaHomeLoadingMore({
    required super.loja,
    required super.produtos,
    required super.produtosPorCategoria,
    required super.selectedCategories,
    required super.activeFilterCount,
    required super.hasMore,
    required super.currentPage,
  });
}
