import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/loja_repository.dart';
import 'loja_home_state.dart';
import '../../../models/secao_model.dart';

class LojaHomeCubit extends Cubit<LojaHomeState> {
  final LojaHomeRepository _repository;
  final int lojaId;
  
  int _currentPage = 1;
  int _totalPages = 1;
  String? _searchQuery;
  int? _selectedCategoriaId;
  String? _orderBy;

  LojaHomeCubit(this._repository, this.lojaId) : super(LojaHomeInitial());

  Future<void> loadLoja({bool reset = true}) async {
    final currentState = state;
    
    if (reset) {
      _currentPage = 1;
      if (currentState is LojaHomeLoaded) {
        // ✅ Mantém as seções antigas e ativa isFiltering para mostrar o overlay semi-transparente
        emit(currentState.copyWith(isFiltering: true, isLoadingMore: false));
      } else {
        emit(LojaHomeLoading());
      }
    } else {
      if (currentState is LojaHomeLoaded) {
        emit(currentState.copyWith(isLoadingMore: true, isFiltering: false));
      } else {
        emit(LojaHomeLoadingMore(secoes: currentState.secoes, loja: currentState.loja));
      }
    }

    try {
      final response = await _repository.getLojaDetalhe(
        id: lojaId,
        page: _currentPage,
        perPage: 20,
        categoriaId: _selectedCategoriaId,
        search: _searchQuery,
        orderBy: _orderBy,
      );

      _totalPages = response.pagination.totalPages;
      
      final List<SecaoModel> currentSecoes = reset ? [] : state.secoes;
      final mergedSecoes = reset ? response.secoes : _mergeSecoes(currentSecoes, response.secoes);

      emit(LojaHomeLoaded(
        loja: response,
        secoes: mergedSecoes,
        selectedCategories: _selectedCategoriaId != null ? [_selectedCategoriaId!] : [],
        orderBy: _orderBy,
        activeFilterCount: (_selectedCategoriaId != null ? 1 : 0) + 
                          (_orderBy != null ? 1 : 0) +
                          (_searchQuery != null && _searchQuery!.isNotEmpty ? 1 : 0),
        hasMore: _currentPage < _totalPages,
        currentPage: _currentPage,
        totalPages: _totalPages,
        searchQuery: _searchQuery,
        pagination: response.pagination,
        filterOptions: response.filterOptions,
        isLoadingMore: false,
        isFiltering: false,
      ));
    } catch (e) {
      emit(LojaHomeError('Erro ao carregar dados da loja: $e', secoes: state.secoes, loja: state.loja));
    }
  }

  void loadMore() {
    if (state is LojaHomeLoaded && _currentPage < _totalPages && !(state as LojaHomeLoaded).isLoadingMore && !(state as LojaHomeLoaded).isFiltering) {
      _currentPage++;
      loadLoja(reset: false);
    }
  }

  List<SecaoModel> _mergeSecoes(List<SecaoModel> current, List<SecaoModel> next) {
    final Map<int, SecaoModel> map = {for (var s in current) s.id: s};
    for (var n in next) {
      if (map.containsKey(n.id)) {
        final existing = map[n.id]!;
        map[n.id] = SecaoModel(
          id: existing.id,
          nome: existing.nome,
          icone: existing.icone,
          ordem: existing.ordem,
          totalProdutos: n.totalProdutos,
          produtos: [...existing.produtos, ...n.produtos],
        );
      } else {
        map[n.id] = n;
      }
    }
    final merged = map.values.toList();
    merged.sort((a, b) => a.ordem.compareTo(b.ordem));
    return merged;
  }

  Future<void> applyFilters({String? search, int? categoriaId, String? orderBy}) async {
    _searchQuery = (search != null && search.trim().isNotEmpty) ? search.trim() : null;
    _selectedCategoriaId = categoriaId;
    _orderBy = orderBy;
    _currentPage = 1;
    await loadLoja(reset: true);
  }

  Future<void> clearFilters() async {
    _searchQuery = null;
    _selectedCategoriaId = null;
    _orderBy = null;
    _currentPage = 1;
    await loadLoja(reset: true);
  }

  Future<void> refresh() async {
    await loadLoja(reset: true);
  }
}
