import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/enums.dart';
import '../cubit/lojas_cubit.dart';
import '../cubit/lojas_state.dart';

class FiltroWidget extends StatelessWidget {
  const FiltroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        if (state is! LojasLoaded) {
          return const Center(child: Text('Filtros indisponíveis'));
        }

        // Para ter mais de 5 categorias, como pedido, vamos duplicar a lista.
        final categories = state.availableCategories.toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categorias',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 colunas
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5, // Controla a proporção altura/largura dos itens
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = state.selectedCategories.contains(category);

                    return FilterChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        context.read<LojasCubit>().toggleCategoryFilter(category);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
