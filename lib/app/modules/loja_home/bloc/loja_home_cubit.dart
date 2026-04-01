import 'package:flutter_bloc/flutter_bloc.dart';
import 'loja_home_state.dart';
import '../../../models/produto_model.dart';
import '../../lojas/models/loja.dart';
import '../../../../shared/api/api_client.dart';

class LojaHomeCubit extends Cubit<LojaHomeState> {
  final ApiClient _apiClient;
  final int lojaId;
  
  int _currentPage = 1;
  bool _hasMore = true;
  List<Produto> _todosProdutos = [];
  String? _searchQuery;
  List<String> _selectedCategories = [];

  LojaHomeCubit(this._apiClient, this.lojaId) : super(LojaHomeInitial());

  Future<void> fetchLojaDetails() async {
    emit(LojaHomeLoading());
    try {
      final lojaResponse = await _apiClient.get('/app/loja/$lojaId');
      
      final produtosResponse = await _apiClient.get(
        '/app/loja/$lojaId/produtos',
        queryParameters: {
          'page': 1,
          'per_page': 10,
          if (_searchQuery != null && _searchQuery!.isNotEmpty) 'search': _searchQuery,
          if (_selectedCategories.isNotEmpty) 'categoria': _selectedCategories.join(','),
        },
      );

      if (lojaResponse.data['success'] == true &&
          produtosResponse.data['success'] == true) {
        
        final loja = Loja.fromJson(lojaResponse.data['data']);
        final items = List<Map<String, dynamic>>.from(produtosResponse.data['data']['items']);
        final pagination = produtosResponse.data['data']['pagination'];
        
        _todosProdutos = items.map((json) => Produto.fromJson(json)).toList();
        _currentPage = pagination['page'];
        _hasMore = _currentPage < pagination['total_pages'];

        emit(LojaHomeLoaded(
          loja: loja,
          produtos: _todosProdutos,
          produtosPorCategoria: _agruparPorCategoria(_todosProdutos),
          selectedCategories: _selectedCategories,
          activeFilterCount: _selectedCategories.length,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ));
      } else {
        emit(LojaHomeError('Erro ao carregar dados'));
      }
    } catch (e) {
      emit(LojaHomeError('Erro de conexão: $e'));
    }
  }

  Future<void> loadMoreProdutos() async {
    if (!_hasMore || state is LojaHomeLoadingMore) return;

    final currentState = state;
    if (currentState is! LojaHomeLoaded) return;

    emit(LojaHomeLoadingMore(
      loja: currentState.loja,
      produtos: currentState.produtos,
      produtosPorCategoria: currentState.produtosPorCategoria,
      selectedCategories: currentState.selectedCategories,
      activeFilterCount: currentState.activeFilterCount,
      hasMore: currentState.hasMore,
      currentPage: currentState.currentPage,
    ));
    
    try {
      final response = await _apiClient.get(
        '/app/loja/$lojaId/produtos',
        queryParameters: {
          'page': _currentPage + 1,
          'per_page': 10,
          if (_searchQuery != null && _searchQuery!.isNotEmpty) 'search': _searchQuery,
          if (_selectedCategories.isNotEmpty) 'categoria': _selectedCategories.join(','),
        },
      );

      if (response.data['success'] == true) {
        final items = List<Map<String, dynamic>>.from(response.data['data']['items']);
        final pagination = response.data['data']['pagination'];
        final novosProdutos = items.map((json) => Produto.fromJson(json)).toList();
        
        _todosProdutos = [..._todosProdutos, ...novosProdutos];
        _currentPage = pagination['page'];
        _hasMore = _currentPage < pagination['total_pages'];

        emit(LojaHomeLoaded(
          loja: currentState.loja,
          produtos: _todosProdutos,
          produtosPorCategoria: _agruparPorCategoria(_todosProdutos),
          selectedCategories: _selectedCategories,
          activeFilterCount: _selectedCategories.length,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ));
      }
    } catch (e) {
      emit(LojaHomeError('Erro ao carregar mais produtos'));
    }
  }

  Future<void> searchQueryChanged(String query) async {
    _searchQuery = query.trim().isEmpty ? null : query;
    await _applyCurrentFiltersAndSearch();
  }

  // 🏷️ APLICAR FILTROS (múltiplos de uma vez)
  Future<void> applyFilters(Set<String> categories) async {
    _selectedCategories = categories.toList();
    await _applyCurrentFiltersAndSearch();
  }

  Future<void> _applyCurrentFiltersAndSearch() async {
    _currentPage = 1;
    _hasMore = true;
    _todosProdutos = [];
    
    Loja? currentLoja;
    if (state is LojaHomeLoaded) {
      currentLoja = (state as LojaHomeLoaded).loja;
    }

    emit(LojaHomeLoading());
    
    try {
      final response = await _apiClient.get(
        '/app/loja/$lojaId/produtos',
        queryParameters: {
          'page': 1,
          'per_page': 10,
          if (_searchQuery != null && _searchQuery!.isNotEmpty) 'search': _searchQuery,
          if (_selectedCategories.isNotEmpty) 'categoria': _selectedCategories.join(','),
        },
      );

      if (response.data['success'] == true) {
        final items = List<Map<String, dynamic>>.from(response.data['data']['items']);
        final pagination = response.data['data']['pagination'];
        
        _todosProdutos = items.map((json) => Produto.fromJson(json)).toList();
        _currentPage = pagination['page'];
        _hasMore = _currentPage < pagination['total_pages'];

        if (currentLoja != null) {
          emit(LojaHomeLoaded(
            loja: currentLoja,
            produtos: _todosProdutos,
            produtosPorCategoria: _agruparPorCategoria(_todosProdutos),
            selectedCategories: _selectedCategories,
            activeFilterCount: _selectedCategories.length,
            hasMore: _hasMore,
            currentPage: _currentPage,
          ));
        } else {
          await fetchLojaDetails();
        }
      }
    } catch (e) {
      emit(LojaHomeError('Erro ao aplicar filtros ou busca: $e'));
    }
  }

  // 🏷️ FILTRAR POR CATEGORIA (individual)
  void toggleCategoryFilter(String categoria) {
    if (_selectedCategories.contains(categoria)) {
      _selectedCategories.remove(categoria);
    } else {
      _selectedCategories.add(categoria);
    }
    _applyCurrentFiltersAndSearch();
  }

  Map<String, List<Produto>> _agruparPorCategoria(List<Produto> produtos) {
    final agrupados = <String, List<Produto>>{};
    for (var p in produtos) {
      final cat = p.categoria;
      if (!agrupados.containsKey(cat)) agrupados[cat] = [];
      agrupados[cat]!.add(p);
    }
    return agrupados;
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    _searchQuery = null;
    _selectedCategories = [];
    _todosProdutos = [];
    await fetchLojaDetails();
  }
}
