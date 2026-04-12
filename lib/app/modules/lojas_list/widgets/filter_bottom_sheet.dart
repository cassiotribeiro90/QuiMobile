import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';

class CategoriaFilter {
  final String label;
  final String? value;
  CategoriaFilter({required this.label, this.value});
}

class FilterBottomSheet extends StatefulWidget {
  final List<CategoriaFilter> categorias;
  final String? selectedCategoria;
  final Function(String?) onApply;

  const FilterBottomSheet({
    super.key,
    required this.categorias,
    this.selectedCategoria,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _tempCategoria;

  @override
  void initState() {
    super.initState();
    _tempCategoria = widget.selectedCategoria;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildCategorias(),
                const SizedBox(height: 20),
                _buildButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Filtrar Lojas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => setState(() => _tempCategoria = null),
          child: const Text('Limpar'),
        ),
      ],
    );
  }

  Widget _buildCategorias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categorias', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Todas', null),
            ...widget.categorias.map((cat) => _buildChip(cat.label, cat.value)),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, String? value) {
    final isSelected = _tempCategoria == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _tempCategoria = isSelected ? null : value),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.orange[100],
      checkmarkColor: Colors.orange,
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onApply(_tempCategoria);
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ),
      ],
    );
  }
}
