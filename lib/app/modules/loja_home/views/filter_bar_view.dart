import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/enums.dart';
import '../../lojas/cubit/lojas_cubit.dart';
import '../../lojas/cubit/lojas_state.dart';

// Helper para adicionar funcionalidades ao enum CategoriaTipo
extension CategoriaHelpers on CategoriaTipo {
  String get displayName => name[0].toUpperCase() + name.substring(1);

  String get emoji {
    switch (this) {
      case CategoriaTipo.hamburgueria:
        return '🍔';
      case CategoriaTipo.pizzaria:
        return '🍕';
      case CategoriaTipo.japonesa:
        return '🍣';
      case CategoriaTipo.brasileira:
        return '🇧🇷';
      case CategoriaTipo.sorvete:
        return '🍦';
      case CategoriaTipo.bebidas:
        return '🥤';
      case CategoriaTipo.saude:
        return '🥗';
      case CategoriaTipo.petiscos:
        return '🥨';
      default:
        return '🍽️';
    }
  }
}

class FiltrosBar extends StatelessWidget {
  const FiltrosBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        if (state is! LojasLoaded) return const SizedBox.shrink();

        final categorias = state.availableCategories.toList(); // Usando availableCategories do state
        // Assumindo que o state tenha um objeto de filtro, ex: state.filtros
        // final filtros = state.filtros;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ordenação (Exemplo, supondo que a lógica exista no Cubit)
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  //_buildOrdenacaoChip(context, '⭐ Melhor avaliação', 'nota', filtros.ordenarPor == 'nota'),
                  //... outros chips
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Filtros de Categoria
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categorias.map((categoria) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        // CORRIGIDO: Usando a nova extension
                          '${CategoriaHelpers(categoria).emoji} ${CategoriaHelpers(categoria).displayName}',
                      ),
                      selected: state.selectedCategories.contains(categoria),
                      onSelected: (_) {
                        context.read<LojasCubit>().toggleCategoryFilter(categoria);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // Função de ordenação corrigida (supondo que o cubit tenha o método ordenarPor)
  Widget _buildOrdenacaoChip(
    BuildContext context,
    String label,
    String valor,
    bool selecionado,
  ) {
    return FilterChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) {
        // context.read<LojasCubit>().ordenarPor(selecionado ? null : valor);
      },
      showCheckmark: false,
    );
  }
}
