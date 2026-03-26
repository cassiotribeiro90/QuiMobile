import 'package:flutter_bloc/flutter_bloc.dart';
import 'lojas_state.dart';
import '../models/loja.dart';
import '../../../../shared/api/api_client.dart';

class LojasCubit extends Cubit<LojasState> {
  final ApiClient _apiClient;
  
  List<Loja> _todasLojas = [];
  List<String> _categoriasSelecionadas = [];
  String? _ordenacaoAtual;
  Map<String, dynamic>? _ultimaPagination;

  LojasCubit(this._apiClient) : super(LojasInitial());

  // 🔍 CARREGAR LOJAS (método principal)
  Future<void> fetchLojas({
    int page = 1,
    int perPage = 10,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        emit(LojasLoading());
      }

      final response = await _apiClient.get(
        '/app/loja/index',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (_categoriasSelecionadas.isNotEmpty) 'categoria': _categoriasSelecionadas.join(','),
          if (_ordenacaoAtual != null) 'order_by': _ordenacaoAtual,
        },
      );

      if (response.data['success'] == true) {
        final items = List<Map<String, dynamic>>.from(response.data['data']['items']);
        final pagination = response.data['data']['pagination'] ?? response.data['data']['_meta'];
        
        final novasLojas = items.map((json) => Loja.fromJson(json)).toList();

        if (isLoadMore && state is LojasLoaded) {
          final currentState = state as LojasLoaded;
          _todasLojas = [...currentState.lojas, ...novasLojas];
        } else {
          _todasLojas = novasLojas;
        }

        _ultimaPagination = pagination;

        // Extrai categorias disponíveis
        final categorias = _todasLojas.map((l) => l.categoria).toSet().toList();
        categorias.sort();

        emit(LojasLoaded(
          lojas: _todasLojas,
          lojasFiltradas: _todasLojas,
          categoriasDisponiveis: categorias,
          categoriasSelecionadas: _categoriasSelecionadas,
          ordenacaoAtual: _ordenacaoAtual,
          pagination: _ultimaPagination,
        ));
      } else {
        emit(LojasError(response.data['message'] ?? 'Erro ao carregar lojas'));
      }
    } catch (e) {
      emit(LojasError('Erro de conexão: $e'));
    }
  }

  // 🔍 FILTRAR POR CATEGORIA
  void toggleCategoryFilter(String categoria) {
    if (_categoriasSelecionadas.contains(categoria)) {
      _categoriasSelecionadas.remove(categoria);
    } else {
      _categoriasSelecionadas.add(categoria);
    }
    
    // Aplica filtro localmente
    if (state is LojasLoaded) {
      final currentState = state as LojasLoaded;
      final lojasFiltradas = currentState.lojas.where((l) {
        if (_categoriasSelecionadas.isEmpty) return true;
        return _categoriasSelecionadas.contains(l.categoria);
      }).toList();
      
      emit(LojasLoaded(
        lojas: currentState.lojas,
        lojasFiltradas: lojasFiltradas,
        categoriasDisponiveis: currentState.categoriasDisponiveis,
        categoriasSelecionadas: _categoriasSelecionadas,
        ordenacaoAtual: _ordenacaoAtual,
        pagination: _ultimaPagination,
      ));
    }
  }

  // 🔍 ORDENAR LOJAS
  void sortLojasBy(String criterio) {
    _ordenacaoAtual = criterio;
    
    if (state is LojasLoaded) {
      final currentState = state as LojasLoaded;
      List<Loja> lojasOrdenadas = List.from(currentState.lojas);
      
      switch (criterio) {
        case 'nota':
          lojasOrdenadas.sort((a, b) => b.notaMedia.compareTo(a.notaMedia));
          break;
        case 'tempo_entrega':
          lojasOrdenadas.sort((a, b) => 
            (a.tempoEntregaMin + a.tempoEntregaMax).compareTo(b.tempoEntregaMin + b.tempoEntregaMax)
          );
          break;
        case 'distancia':
          lojasOrdenadas.sort((a, b) => (a.distancia ?? 999).compareTo(b.distancia ?? 999));
          break;
        default:
          lojasOrdenadas.sort((a, b) => b.notaMedia.compareTo(a.notaMedia));
      }
      
      // Aplica filtro de categoria
      final lojasFiltradas = lojasOrdenadas.where((l) {
        if (_categoriasSelecionadas.isEmpty) return true;
        return _categoriasSelecionadas.contains(l.categoria);
      }).toList();
      
      emit(LojasLoaded(
        lojas: lojasOrdenadas,
        lojasFiltradas: lojasFiltradas,
        categoriasDisponiveis: currentState.categoriasDisponiveis,
        categoriasSelecionadas: _categoriasSelecionadas,
        ordenacaoAtual: _ordenacaoAtual,
        pagination: _ultimaPagination,
      ));
    }
  }

  // 🔄 LIMPAR FILTROS
  void clearFilters() {
    _categoriasSelecionadas = [];
    _ordenacaoAtual = null;
    
    if (state is LojasLoaded) {
      final currentState = state as LojasLoaded;
      emit(LojasLoaded(
        lojas: currentState.lojas,
        lojasFiltradas: currentState.lojas,
        categoriasDisponiveis: currentState.categoriasDisponiveis,
        categoriasSelecionadas: [],
        ordenacaoAtual: null,
        pagination: _ultimaPagination,
      ));
    }
  }

  // 🔍 BUSCAR LOJAS
  void searchLojas(String query) {
    if (state is LojasLoaded) {
      final currentState = state as LojasLoaded;
      final lojasFiltradas = currentState.lojas.where((l) {
        return l.nome.toLowerCase().contains(query.toLowerCase()) ||
               l.cidade.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      emit(LojasLoaded(
        lojas: currentState.lojas,
        lojasFiltradas: lojasFiltradas,
        categoriasDisponiveis: currentState.categoriasDisponiveis,
        categoriasSelecionadas: _categoriasSelecionadas,
        ordenacaoAtual: _ordenacaoAtual,
        pagination: _ultimaPagination,
      ));
    }
  }

  // 🔄 RECARREGAR LISTA
  Future<void> refreshList() async {
    await fetchLojas(page: 1);
  }

  // ✅ GETTERS
  bool get hasMorePages {
    if (_ultimaPagination == null) return false;
    final currentPageNum = _ultimaPagination!['page'] ?? _ultimaPagination!['currentPage'] ?? 1;
    final totalPagesNum = _ultimaPagination!['total_pages'] ?? _ultimaPagination!['pageCount'] ?? 1;
    return currentPageNum < totalPagesNum;
  }

  int get currentPage => _ultimaPagination?['page'] ?? _ultimaPagination?['currentPage'] ?? 1;
  int get totalPages => _ultimaPagination?['total_pages'] ?? _ultimaPagination?['pageCount'] ?? 1;
}
