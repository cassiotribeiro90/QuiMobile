import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import '../../../models/loja_model.dart';
import '../../../models/produto_model.dart';
import '../repositories/loja_repository.dart';
import '../repositories/produto_repository.dart';
import 'loja_home_state.dart';

class LojaHomeCubit extends Cubit<LojaHomeState> {
  final ILojaRepository _lojaRepository;
  final IProdutoRepository _produtoRepository;
  final int lojaId;

  LojaHomeCubit(this._lojaRepository, this._produtoRepository, this.lojaId)
      : super(LojaHomeInitial());

  Future<void> fetchLojaDetails() async {
    try {
      emit(LojaHomeLoading());

      final results = await Future.wait([
        _lojaRepository.getLojaById(lojaId),
        _produtoRepository.getProdutosByLojaId(lojaId),
      ]);

      final loja = results[0] as Loja;
      final produtos = results[1] as List<Produto>;
      final categories = produtos.map((p) => p.categoria).toSet();

      emit(LojaHomeLoaded(
        loja: loja,
        allProdutos: produtos,
        filteredProdutos: produtos,
        produtosPorCategoria: _groupProdutosByCategoria(produtos),
        availableCategories: categories,
        selectedCategories: categories, // Começa com todas selecionadas
        searchQuery: '',
      ));
    } catch (e) {
      emit(LojaHomeError(e.toString()));
    }
  }

  void searchQueryChanged(String query) {
    if (state is! LojaHomeLoaded) return;
    final currentState = state as LojaHomeLoaded;
    emit(currentState.copyWith(searchQuery: query));
    _applyFiltersAndSearch();
  }

  void toggleCategoryFilter(String category) {
    if (state is! LojaHomeLoaded) return;
    final currentState = state as LojaHomeLoaded;
    final currentSelected = currentState.selectedCategories.toSet();

    if (currentSelected.contains(category)) {
      currentSelected.remove(category);
    } else {
      currentSelected.add(category);
    }
    emit(currentState.copyWith(selectedCategories: currentSelected));
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    if (state is! LojaHomeLoaded) return;
    final currentState = state as LojaHomeLoaded;

    List<Produto> tempProdutos = List.from(currentState.allProdutos);

    // 1. Filtro de Categoria
    if (currentState.selectedCategories.isNotEmpty && currentState.selectedCategories.length < currentState.availableCategories.length) {
      tempProdutos = tempProdutos.where((p) => currentState.selectedCategories.contains(p.categoria)).toList();
    }

    // 2. Filtro de Busca (Query)
    if (currentState.searchQuery.isNotEmpty) {
      tempProdutos = tempProdutos.where((p) => p.nome.toLowerCase().contains(currentState.searchQuery.toLowerCase())).toList();
    }

    emit(currentState.copyWith(
      filteredProdutos: tempProdutos,
      produtosPorCategoria: _groupProdutosByCategoria(tempProdutos),
    ));
  }

  Map<String, List<Produto>> _groupProdutosByCategoria(List<Produto> produtos) {
    return groupBy(produtos, (Produto p) => p.categoria);
  }

  void applyCategoryFilter(Set<String> selectedCategories) {}
}
