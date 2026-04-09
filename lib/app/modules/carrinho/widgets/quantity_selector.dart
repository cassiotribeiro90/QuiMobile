import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int min;
  final int max;
  final Function(int) onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    this.min = 0, // ✅ Permitindo 0 para possibilitar remoção completa
    this.max = 99,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            context: context,
            icon: Icons.remove,
            onTap: () {
              if (quantity > min) {
                onChanged(quantity - 1);
              }
            },
            enabled: quantity > min,
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
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
            enabled: quantity < max,
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
