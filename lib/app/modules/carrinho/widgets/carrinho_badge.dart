import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/carrinho_cubit.dart';
import '../../../core/theme/app_theme_extension.dart';

class CarrinhoBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const CarrinhoBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarrinhoCubit, CarrinhoState>(
      builder: (context, state) {
        int totalItens = 0;
        
        // Confiamos apenas no resumo vindo da API através do Cubit
        if (state is CarrinhoLoaded) {
          totalItens = state.totalItens;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: onTap,
            ),
            if (totalItens > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    totalItens > 99 ? '99+' : totalItens.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
