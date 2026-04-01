import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/loja_home_cubit.dart';
import '../bloc/loja_home_state.dart';
class FilterBarView extends StatelessWidget {
  const FilterBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojaHomeCubit, LojaHomeState>(
      builder: (context, state) {
        if (state is! LojaHomeLoaded) return const SizedBox.shrink();

        final cubit = context.read<LojaHomeCubit>();
        final categorias = state.selectedCategories.toList();

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              final isSelected = state.selectedCategories.contains(categoria);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(categoria),
                  selected: isSelected,
                  onSelected: (_) => cubit.toggleCategoryFilter(categoria),
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  checkmarkColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
