import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final String? itemName; // ✅ Nome do item para o diálogo
  final int max;
  final bool isLoading; // ✅ Recebe se está carregando

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.itemName,
    this.max = 99,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLoading ? context.borderColor.withOpacity(0.5) : context.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            context: context,
            icon: Icons.remove,
            onTap: () {
              if (quantity == 1) {
                // ✅ Quando quantidade é 1 e vai para 0, mostra diálogo
                _showRemoveDialog(context);
              } else if (quantity > 1) {
                onChanged(quantity - 1);
              }
            },
            enabled: !isLoading && quantity >= 1,
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    quantity.toString(),
                    style: context.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                  ),
          ),
          _buildButton(
            context: context,
            icon: Icons.add,
            onTap: () {
              if (quantity < max) {
                onChanged(quantity + 1);
              }
            },
            enabled: !isLoading && quantity < max,
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover item'),
        content: Text(
          itemName != null 
              ? 'Deseja remover "$itemName" do carrinho?'
              : 'Deseja remover este item do carrinho?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onChanged(0); // ✅ Confirma remoção
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? context.primaryColor : context.textHint,
        ),
      ),
    );
  }
}
