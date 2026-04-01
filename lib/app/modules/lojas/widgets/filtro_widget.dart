import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';

class FiltroWidget extends StatelessWidget {
  const FiltroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocBuilder<LojasCubit, LojasState>(
        builder: (context, state) {
          if (state is LojasLoaded) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => context.read<LojasCubit>().clearAllFilters(),
                        child: const Text('Limpar'),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Categorias
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Categorias', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Wrap(
                    spacing: 8,
                    children: state.categorias.map((cat) {
                      final isSelected = state.categoriaSelecionada == cat.value;
                      return FilterChip(
                        label: Text(cat.label),
                        selected: isSelected,
                        onSelected: (_) => context.read<LojasCubit>().filterByCategoria(cat.value),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  // Ordenação
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Ordenar por', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildSortButton(context, 'Melhor nota', 'nota', null), // Ordenação não implementada no novo Cubit
                          const SizedBox(width: 8),
                          _buildSortButton(context, 'Menor tempo', 'tempo_entrega', null),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildSortButton(context, 'Mais perto', 'distancia', null),
                          const SizedBox(width: 8),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, String label, String valor, String? atual) {
    final isSelected = atual == valor;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          // Implementar ordenação no Cubit se necessário
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
