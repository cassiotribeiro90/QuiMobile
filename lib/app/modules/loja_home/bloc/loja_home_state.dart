import 'package:equatable/equatable.dart';
import '../../../models/loja_detalhe_model.dart';
import '../../../models/secao_model.dart';
import '../../../models/pagination_model.dart';
import '../../../models/filter_options_model.dart';

abstract class LojaHomeState extends Equatable {
  final List<SecaoModel> secoes;
  final LojaDetalheModel? loja;
  
  const LojaHomeState({
    this.secoes = const [],
    this.loja,
  });

  @override
  List<Object?> get props => [secoes, loja];
}

class LojaHomeInitial extends LojaHomeState {
  const LojaHomeInitial() : super();
}

class LojaHomeLoading extends LojaHomeState {
  const LojaHomeLoading({super.secoes, super.loja});
}

class LojaHomeLoaded extends LojaHomeState {
  @override
  final LojaDetalheModel loja;
  final PaginationModel pagination;
  final LojaFilterOptions filterOptions;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isFiltering;
  final int? selectedCategoriaId;
  final String? searchQuery;
  final String? orderBy;
  final List<int> selectedCategories;
  final int currentPage;
  final int totalPages;
  final int activeFilterCount;

  const LojaHomeLoaded({
    required this.loja,
    required super.secoes,
    required this.pagination,
    required this.filterOptions,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isFiltering = false,
    this.selectedCategoriaId,
    this.searchQuery,
    this.orderBy,
    this.selectedCategories = const [],
    required this.currentPage,
    required this.totalPages,
    required this.activeFilterCount,
  }) : super(loja: loja);

  LojaHomeLoaded copyWith({
    LojaDetalheModel? loja,
    List<SecaoModel>? secoes,
    PaginationModel? pagination,
    LojaFilterOptions? filterOptions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFiltering,
    int? selectedCategoriaId,
    String? searchQuery,
    String? orderBy,
    List<int>? selectedCategories,
    int? currentPage,
    int? totalPages,
    int? activeFilterCount,
  }) {
    return LojaHomeLoaded(
      loja: loja ?? this.loja,
      secoes: secoes ?? this.secoes,
      pagination: pagination ?? this.pagination,
      filterOptions: filterOptions ?? this.filterOptions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFiltering: isFiltering ?? this.isFiltering,
      selectedCategoriaId: selectedCategoriaId ?? this.selectedCategoriaId,
      searchQuery: searchQuery ?? this.searchQuery,
      orderBy: orderBy ?? this.orderBy,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      activeFilterCount: activeFilterCount ?? this.activeFilterCount,
    );
  }

  @override
  List<Object?> get props => [
        loja,
        secoes,
        pagination,
        filterOptions,
        hasMore,
        isLoadingMore,
        isFiltering,
        selectedCategoriaId,
        searchQuery,
        orderBy,
        selectedCategories,
        currentPage,
        totalPages,
        activeFilterCount,
      ];
}

class LojaHomeError extends LojaHomeState {
  final String message;
  const LojaHomeError(this.message, {super.secoes, super.loja});
  @override
  List<Object?> get props => [message, secoes, loja];
}

class LojaHomeLoadingMore extends LojaHomeState {
  const LojaHomeLoadingMore({super.secoes, super.loja});
}
