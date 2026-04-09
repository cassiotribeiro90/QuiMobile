import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/carrinho_cubit.dart';
import '../../../core/theme/app_theme_extension.dart';

class CarrinhoPage extends StatelessWidget {
  const CarrinhoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimary,
        elevation: 0,
      ),
      backgroundColor: context.backgroundColor,
      body: BlocBuilder<CarrinhoCubit, CarrinhoState>(
        builder: (context, state) {
          if (state is CarrinhoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CarrinhoLoaded) {
            if (state.itens.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 64, color: context.textHint),
                    const SizedBox(height: 16),
                    Text(
                      'Seu carrinho está vazio',
                      style: context.bodyLarge.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.itens.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = state.itens[index];
                      return ListTile(
                        title: Text(item.nome),
                        subtitle: Text('Quantidade: ${item.quantidade}'),
                        trailing: Text(
                          'R\$ ${item.precoTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: context.bodyLarge),
                            Text(
                              'R\$ ${state.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implementar checkout
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Finalizar Pedido'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is CarrinhoError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
