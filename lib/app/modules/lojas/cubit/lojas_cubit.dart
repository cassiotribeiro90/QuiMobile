import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_service.dart';
import '../../../models/enums.dart';
import '../../../models/loja_model.dart';
import 'lojas_state.dart';

class LojasCubit extends Cubit<LojasState> {
  final ApiService? _apiService;

  LojasCubit({ApiService? apiService}) : _apiService = apiService, super(LojasInitial());

  Future<void> loadLojas() async {
    emit(LojasLoading());
    try {
      // Simulação de carregamento (você deve plugar seu repository real aqui)
      final List<Loja> mockLojas = []; 
      
      emit(LojasLoaded(
        allLojas: mockLojas,
        filteredLojas: mockLojas,
        availableCategories: CategoriaTipo.values.toSet(),
        selectedCategories: const {},
        ordenacaoAtual: OrdenacaoTipo.padrao,
      ));
    } catch (e) {
      emit(LojasError(e.toString()));
    }
  }

  // Nome conforme filtros_bar.dart
  void toggleCategoryFilter(CategoriaTipo categoria) {
    if (state is LojasLoaded) {
      final s = state as LojasLoaded;
      final novasCategorias = Set<CategoriaTipo>.from(s.selectedCategories);
      if (novasCategorias.contains(categoria)) {
        novasCategorias.remove(categoria);
      } else {
        novasCategorias.add(categoria);
      }
      _aplicarFiltros(s.copyWith(selectedCategories: novasCategorias));
    }
  }

  // Nome conforme filtros_bar.dart
  void sortLojasBy(OrdenacaoTipo ordenacao) {
    if (state is LojasLoaded) {
      final s = state as LojasLoaded;
      _aplicarFiltros(s.copyWith(ordenacaoAtual: ordenacao));
    }
  }

  void _aplicarFiltros(LojasLoaded stateAtual) {
    var filtradas = List<Loja>.from(stateAtual.allLojas);
    
    if (stateAtual.selectedCategories.isNotEmpty) {
      filtradas = filtradas.where((l) => stateAtual.selectedCategories.contains(l.categoria)).toList();
    }

    if (stateAtual.ordenacaoAtual == OrdenacaoTipo.nota) {
      filtradas.sort((a, b) => b.nota.compareTo(a.nota));
    }

    emit(stateAtual.copyWith(filteredLojas: filtradas));
  }

  Future<void> criarLoja(Map<String, dynamic> dadosLoja) async {
    try {
      if (_apiService != null) {
        await _apiService.post('/lojas', data: dadosLoja);
        loadLojas();
      }
    } catch (e) {
      emit(LojasError(e.toString()));
    }
  }
}
