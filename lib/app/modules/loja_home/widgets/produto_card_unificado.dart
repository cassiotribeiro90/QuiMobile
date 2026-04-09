import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../models/produto_model.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../carrinho/widgets/quantity_selector.dart';
import '../../../../shared/services/token_service.dart';

class ProdutoCardUnificado extends StatelessWidget {
  final ProdutoModel produto;
  final int lojaId;
  final int quantidadeNoCarrinho;
  final int? itemIdNoCarrinho;
  final VoidCallback? onTap;

  static int _instanciasCriadas = 0;
  static int _buildCount = 0;
  final int _instanciaId;

  ProdutoCardUnificado({
    required Key key,
    required this.produto,
    required this.lojaId,
    required this.quantidadeNoCarrinho,
    this.itemIdNoCarrinho,
    this.onTap,
  })  : _instanciaId = ++_instanciasCriadas,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    print('🎴 [ProdutoCard] INSTÂNCIA #$_instanciaId - BUILD #$_buildCount');
    print('   Produto: ID=${produto.id} - ${produto.nome}');
    print('   Quantidade no carrinho: $quantidadeNoCarrinho');

    final temNoCarrinho = quantidadeNoCarrinho > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          border: Border(
            bottom: BorderSide(color: context.dividerColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (produto.destaque) _buildDestaqueBadge(context),
                  Text(
                    produto.nome,
                    style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (produto.descricao != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      produto.descricao!,
                      style: context.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildPreco(context),
                  const SizedBox(height: 4),
                  _buildInfo(context),
                  const SizedBox(height: 12),
                  if (temNoCarrinho && itemIdNoCarrinho != null)
                    QuantitySelector(
                      quantity: quantidadeNoCarrinho,
                      onChanged: (novaQuantidade) {
                        if (novaQuantidade == 0) {
                          context.read<CarrinhoCubit>().removerItem(itemIdNoCarrinho!);
                        } else {
                          context.read<CarrinhoCubit>().atualizarQuantidade(itemIdNoCarrinho!, novaQuantidade);
                        }
                      },
                    )
                  else
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _handleAdicionar(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Adicionar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            if (produto.imagem != null) ...[
              const SizedBox(width: 16),
              _buildImagem(context),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAdicionar(BuildContext context) {
    if (!TokenService().isLoggedIn()) {
      _showLoginDialog(context);
      return;
    }

    context.read<CarrinhoCubit>().adicionarItemSimples(
          produtoId: produto.id,
          lojaId: lojaId,
          nome: produto.nome,
          imagem: produto.imagem,
          preco: produto.precoAtual,
        );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entre para continuar'),
        content: const Text('Para adicionar itens à sua sacola, você precisa estar conectado à sua conta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDestaqueBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fireplace, size: 12, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            'DESTAQUE',
            style: context.bodySmall?.copyWith(
              color: Colors.orange[900],
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreco(BuildContext context) {
    if (produto.precoPromocional != null) {
      return Row(
        children: [
          Text(
            'R\$ ${produto.precoPromocional!.toStringAsFixed(2).replaceAll('.', ',')}',
            style: context.bodyMedium?.copyWith(
              color: context.successColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
            style: context.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }
    return Text(
      produto.precoFormatado,
      style: context.bodyMedium?.copyWith(
        color: context.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Row(
      children: [
        if (produto.tempoPreparo != null) ...[
          Icon(Icons.timer_outlined, size: 14, color: context.textSecondary),
          const SizedBox(width: 4),
          Text('${produto.tempoPreparo} min', style: context.bodySmall),
        ],
        if (produto.notaMedia > 0) ...[
          const SizedBox(width: 8),
          Icon(Icons.star, size: 14, color: context.ratingColor),
          const SizedBox(width: 4),
          Text(
            produto.notaMedia.toString(),
            style: context.bodySmall?.copyWith(color: context.ratingColor, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }

  Widget _buildImagem(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: produto.imagem!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
      ),
    );
  }
}
