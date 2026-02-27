import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/enums.dart';
import '../cubit/lojas_cubit.dart';
import '../cubit/lojas_state.dart';

class FiltrosBar extends StatelessWidget {
  const FiltrosBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        if (state is! LojasLoaded) return const SizedBox.shrink();

        final cubit = context.read<LojasCubit>();
        final categorias = state.availableCategories.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text('Ordenar por', style: Theme.of(context).textTheme.titleSmall),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8.0,
                children: [
                  _buildOrdenacaoChip(context, 'Padrão', OrdenacaoTipo.padrao, state.ordenacaoAtual == OrdenacaoTipo.padrao),
                  _buildOrdenacaoChip(context, '⭐ Avaliação', OrdenacaoTipo.nota, state.ordenacaoAtual == OrdenacaoTipo.nota),
                  _buildOrdenacaoChip(context, '📍 Distância', OrdenacaoTipo.distancia, state.ordenacaoAtual == OrdenacaoTipo.distancia),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Filtrar por Categoria', style: Theme.of(context).textTheme.titleSmall),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8.0,
                children: categorias.map((categoria) {
                  return FilterChip(
                    label: Text('${categoria.emoji} ${categoria.displayName}'),
                    selected: state.selectedCategories.contains(categoria),
                    onSelected: (_) => cubit.toggleCategoryFilter(categoria),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdenacaoChip(
    BuildContext context,
    String label,
    OrdenacaoTipo tipo,
    bool selecionado,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) {
        context.read<LojasCubit>().sortLojasBy(tipo);
      },
    );
  }
}
