import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';

class FiltrosBar extends StatelessWidget {
  const FiltrosBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        if (state is! LojasLoaded) return const SizedBox.shrink();

        final cubit = context.read<LojasCubit>();
        final categorias = state.categoriasDisponiveis;

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
              child: Row(
                children: [
                  _buildOrdenacaoChip(context, 'Melhor Nota', 'nota', state.ordenacaoAtual == 'nota'),
                  const SizedBox(width: 8),
                  _buildOrdenacaoChip(context, 'Mais Rápido', 'tempo_entrega', state.ordenacaoAtual == 'tempo_entrega'),
                  const SizedBox(width: 8),
                  _buildOrdenacaoChip(context, 'Mais Próximo', 'distancia', state.ordenacaoAtual == 'distancia'),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Categorias', style: Theme.of(context).textTheme.titleSmall),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: categorias.map((categoria) {
                  final isSelected = state.categoriasSelecionadas.contains(categoria);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(categoria),
                      selected: isSelected,
                      onSelected: (_) => cubit.toggleCategoryFilter(categoria),
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

  Widget _buildOrdenacaoChip(
    BuildContext context,
    String label,
    String tipo,
    bool selecionado,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (selected) {
        if (selected) {
          context.read<LojasCubit>().sortLojasBy(tipo);
        }
      },
    );
  }
}
