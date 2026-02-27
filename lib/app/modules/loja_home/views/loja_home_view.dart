import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/loja_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../cubit/loja_home_cubit.dart';
import '../cubit/loja_home_state.dart';

class LojaHomeView extends StatelessWidget {
  const LojaHomeView({super.key});

  IconData _getPagamentoIcon(String pagamento) {
    switch (pagamento.toLowerCase()) {
      case 'credito':
      case 'debito':
        return Icons.credit_card;
      case 'pix':
        return Icons.qr_code;
      case 'dinheiro':
        return Icons.money;
      case 'vr':
        return Icons.fastfood;
      default:
        return Icons.payment;
    }
  }

  String _formatPagamento(String pagamento) {
    return pagamento[0].toUpperCase() + pagamento.substring(1);
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<LojaHomeCubit, LojaHomeState>(
        builder: (context, state) {
          if (state is LojaHomeLoading || state is LojaHomeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LojaHomeError) {
            return Center(child: Text(state.message));
          } else if (state is LojaHomeLoaded) {
            final loja = state.loja;
            final textTheme = Theme.of(context).textTheme;
            final colorScheme = Theme.of(context).colorScheme;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: loja.capa,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(color: AppTheme.lightGreyColor),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.black.withOpacity(0.6)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.3, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(imageUrl: loja.logo, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(loja.nome, style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: loja.isOpenNow ? Colors.green : Colors.red)),
                                        const SizedBox(width: 4),
                                        Text(loja.isOpenNow ? 'Aberto agora' : 'Fechado', style: TextStyle(color: loja.isOpenNow ? Colors.green[300] : Colors.red[300], fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoItem(icon: Icons.star, value: loja.nota.toStringAsFixed(1), label: 'Avaliação', color: colorScheme.secondary),
                              _buildInfoItem(icon: Icons.access_time, value: loja.tempoEntregaFormatado, label: 'Entrega', color: AppTheme.primaryColor),
                              _buildInfoItem(icon: Icons.motorcycle, value: loja.taxaEntregaFormatada, label: 'Taxa', color: loja.taxaEntrega == 0 ? Colors.green : Colors.orange),
                              _buildInfoItem(icon: Icons.shopping_bag, value: 'R\$ ${loja.pedidoMinimo.toStringAsFixed(2)}', label: 'Mínimo', color: Colors.blue),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (loja.descricao.isNotEmpty) ...[
                          const Text('Sobre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(loja.descricao, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                          const SizedBox(height: 16),
                        ],
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                          child: Row(
                            children: [
                              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 24)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Endereço', style: TextStyle(fontSize: 12, color: Colors.grey)), Text(loja.enderecoCompleto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))])),
                              IconButton(icon: const Icon(Icons.map, color: AppTheme.primaryColor), onPressed: () {}),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Formas de pagamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                children: loja.formasPagamento.map((pagamento) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[300]!)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_getPagamentoIcon(pagamento.name), size: 16, color: AppTheme.primaryColor), const SizedBox(width: 4), Text(_formatPagamento(pagamento.name), style: const TextStyle(fontSize: 12))]),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(Routes.LOJA_AVALIACOES, arguments: loja.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Avaliações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
