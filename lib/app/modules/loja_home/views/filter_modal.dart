import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

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

  // Categorias de exemplo (depois viriam do repository)
  final List<String> _availableCategories = [
    'Hambúrgueres',
    'Porções',
    'Bebidas',
    'Sobremesas',
    'Combos',
    'Vegetariano',
  ];

  @override
  void initState() {
    super.initState();
    _tempSelectedCategories = Set.from(widget.selectedCategories);
    _tempPriceRange = widget.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Alça do modal
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filtrar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempSelectedCategories.clear();
                      _tempPriceRange = const RangeValues(0, 150);
                    });
                  },
                  child: const Text('Limpar'),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categorias
                  const Text(
                    'Categorias',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCategories.map((category) {
                      final isSelected = _tempSelectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _tempSelectedCategories.add(category);
                            } else {
                              _tempSelectedCategories.remove(category);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                        checkmarkColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Faixa de preço
                  const Text(
                    'Faixa de preço',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _tempPriceRange,
                    min: 0,
                    max: 150,
                    divisions: 30,
                    activeColor: AppTheme.primaryColor,
                    labels: RangeLabels(
                      'R\$ ${_tempPriceRange.start.round()}',
                      'R\$ ${_tempPriceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _tempPriceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R\$ ${_tempPriceRange.start.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'R\$ ${_tempPriceRange.end.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Ordenação
                  const Text(
                    'Ordenar por',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOrderOption('Recomendados', true),
                  _buildOrderOption('Menor preço', false),
                  _buildOrderOption('Maior preço', false),
                  _buildOrderOption('Melhor avaliação', false),
                ],
              ),
            ),
          ),

          // Botões de ação
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempSelectedCategories, _tempPriceRange);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

  Widget _buildOrderOption(String label, bool isSelected) {
    return RadioListTile(
      title: Text(label),
      value: label,
      groupValue: isSelected ? label : null,
      onChanged: (value) {},
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }
}