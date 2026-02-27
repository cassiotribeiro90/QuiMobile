import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import '../../../models/enums.dart';
import 'lojas_state.dart';
import '../../../models/loja_model.dart';

class LojasCubit extends Cubit<LojasState> {
  LojasCubit() : super(LojasInitial());

  Future<void> loadLojas() async {
    const String assetPath = 'lib/app/assets/data/lojas.json';

    try {
      emit(LojasLoading());

      await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/assets',
        const StandardMethodCodec().encodeMethodCall(MethodCall('evict', assetPath)),
            (ByteData? data) {},
      );

      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> lojasData = jsonData['lojas'] as List<dynamic>;
      final List<Loja> lojas = lojasData.map((data) => Loja.fromJson(data)).toList();

      final Set<CategoriaTipo> availableCategories = lojas.map((loja) => loja.categoria).toSet();

      emit(LojasLoaded(
        allLojas: lojas,
        filteredLojas: lojas,
        availableCategories: availableCategories,
        selectedCategories: availableCategories,
        ordenacaoAtual: OrdenacaoTipo.padrao,
      ));
    } catch (e) {
      emit(LojasError('Falha ao decodificar os dados: ${e.toString()}'));
    }
  }

  void applyFiltersAndSort({Set<CategoriaTipo>? newSelectedCategories, OrdenacaoTipo? newOrdenacao}) {
    if (state is! LojasLoaded) return;

    final currentState = state as LojasLoaded;
    final selectedCategories = newSelectedCategories ?? currentState.selectedCategories;
    final ordenacao = newOrdenacao ?? currentState.ordenacaoAtual;

    // 1. Filtrar
    List<Loja> filtered = currentState.allLojas.where((loja) {
      return selectedCategories.contains(loja.categoria);
    }).toList();

    // 2. Ordenar
    switch (ordenacao) {
      case OrdenacaoTipo.nota:
        filtered.sort((a, b) => b.nota.compareTo(a.nota));
        break;
      case OrdenacaoTipo.distancia:
        filtered.sort((a, b) {
          if (a.distanciaKm == null) return 1;
          if (b.distanciaKm == null) return -1;
          return a.distanciaKm!.compareTo(b.distanciaKm!);
        });
        break;
      case OrdenacaoTipo.padrao:
        // Nenhuma ordenação específica, mantém a ordem original do filtro
        break;
    }

    emit(currentState.copyWith(
      selectedCategories: selectedCategories,
      ordenacaoAtual: ordenacao,
      filteredLojas: filtered,
    ));
  }

  void toggleCategoryFilter(CategoriaTipo category) {
    if (state is! LojasLoaded) return;
    final currentState = state as LojasLoaded;
    final currentSelected = currentState.selectedCategories.toSet();

    if (currentSelected.contains(category)) {
      currentSelected.remove(category);
    } else {
      currentSelected.add(category);
    }
    applyFiltersAndSort(newSelectedCategories: currentSelected);
  }

  void sortLojasBy(OrdenacaoTipo tipo) {
    applyFiltersAndSort(newOrdenacao: tipo);
  }
}
