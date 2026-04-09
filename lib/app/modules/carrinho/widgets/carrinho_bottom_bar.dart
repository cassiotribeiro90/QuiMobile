import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/carrinho_cubit.dart';
import '../../../core/theme/app_theme_extension.dart';

class CarrinhoBottomBar extends StatelessWidget {
  final VoidCallback onTap;
  final String lojaNome;

  const CarrinhoBottomBar({
    super.key,
    required this.onTap,
    required this.lojaNome,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarrinhoCubit, CarrinhoState>(
      builder: (context, state) {
        int totalItens = 0;
        double subtotal = 0;
        
        if (state is CarrinhoLoaded) {
          totalItens = state.totalItens;
          subtotal = state.subtotal;
        }
        
        if (totalItens == 0) {
          return const SizedBox.shrink();
        }
        
        return Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sacola - $lojaNome',
                            style: context.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$totalItens ${totalItens == 1 ? 'item' : 'itens'}',
                            style: context.bodySmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Row(
                      children: [
                        Text(
                          'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: context.titleSmall.copyWith(
                            color: context.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios, 
                          size: 14, 
                          color: context.primaryColor
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
