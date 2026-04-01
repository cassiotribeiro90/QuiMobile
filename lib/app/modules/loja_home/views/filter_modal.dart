import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/loja_home_cubit.dart';

class FilterModal extends StatefulWidget {
  final Set<String> selectedCategories;
  final RangeValues priceRange;
  final Function(Set<String>, RangeValues) onApply;

  const FilterModal({
    super.key,
    required this.selectedCategories,
    required this.priceRange,
    required this.onApply,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late Set<String> _tempSelectedCategories;
  late RangeValues _tempPriceRange;

  // Categorias disponíveis
  final List<String> _availableCategories = [
    'Pizzas',
    'Bebidas',
    'Sobremesas',
    'Hambúrgueres',
    'Massas',
    'Entradas',
  ];

  @override
  void initState() {
    super.initState();
    _tempSelectedCategories = Set.from(widget.selectedCategories);
    _tempPriceRange = widget.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtrar Cardápio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Conteúdo
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção de Categorias
                  const Text(
                    'Categorias',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCategories.map((categoria) {
                      final isSelected = _tempSelectedCategories.contains(categoria);
                      return FilterChip(
                        label: Text(categoria),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _tempSelectedCategories.add(categoria);
                            } else {
                              _tempSelectedCategories.remove(categoria);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                        checkmarkColor: theme.colorScheme.primary,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Seção de Faixa de Preço
                  const Text(
                    'Faixa de Preço',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: _tempPriceRange,
                    min: 0,
                    max: 150,
                    divisions: 15,
                    labels: RangeLabels(
                      'R\$ ${_tempPriceRange.start.toStringAsFixed(0)}',
                      'R\$ ${_tempPriceRange.end.toStringAsFixed(0)}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _tempPriceRange = values;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(height: 1),
          
          // Botões
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _tempSelectedCategories.clear();
                        _tempPriceRange = const RangeValues(0, 150);
                      });
                    },
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ APLICAR FILTROS
                      context.read<LojaHomeCubit>().applyFilters(_tempSelectedCategories);
                      widget.onApply(_tempSelectedCategories, _tempPriceRange);
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
