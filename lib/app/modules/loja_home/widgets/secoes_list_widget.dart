import 'package:flutter/material.dart';
import '../../../models/secao_model.dart';
import '../../../models/produto_model.dart';
import 'produto_card_widget.dart';
import '../../../core/theme/app_theme_extension.dart';

class SecoesListWidget extends StatelessWidget {
  final List<SecaoModel> secoes;
  final Function(ProdutoModel) onProdutoTap;

  const SecoesListWidget({
    super.key,
    required this.secoes,
    required this.onProdutoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (secoes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: context.textHint),
              const SizedBox(height: 16),
              Text(
                'Nenhum produto encontrado',
                style: context.bodyLarge.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final secao = secoes[index];
          if (secao.produtos.isEmpty) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da seção
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    if (secao.icone != null) ...[
                      Text(secao.icone!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        secao.nome,
                        style: context.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${secao.totalProdutos}',
                        style: context.caption.copyWith(
                          color: context.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Produtos da seção
              ...secao.produtos.map(
                (produto) => ProdutoCardWidget(
                  produto: produto,
                  onTap: () => onProdutoTap(produto),
                ),
              ),
              // Divisor entre seções
              if (index < secoes.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: context.dividerColor, thickness: 1),
                ),
            ],
          );
        },
        childCount: secoes.length,
      ),
    );
  }
}
