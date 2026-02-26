import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/loja_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../cubit/lojas_cubit.dart';
import '../cubit/lojas_state.dart';

class LojasView extends StatefulWidget {
  const LojasView({super.key});

  @override
  State<LojasView> createState() => _LojasViewState();
}

class _LojasViewState extends State<LojasView> {
  @override
  void initState() {
    super.initState();
    context.read<LojasCubit>().loadLojas();
  }

  Future<void> _onRefresh() async {
    context.read<LojasCubit>().loadLojas();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        Widget body;
        if (state is LojasLoading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (state is LojasError) {
          body = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(state.message, style: AppTheme.errorTextStyle, textAlign: TextAlign.center),
            ),
          );
        } else if (state is LojasLoaded) {
          if (state.lojas.isEmpty) {
            body = const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: Text('Nenhuma loja encontrada na sua região.', style: AppTheme.errorTextStyle),
              ),
            );
          } else {
            body = RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildLojasList(state.lojas),
            );
          }
        } else {
          body = const SizedBox.shrink();
        }
        return body;
      },
    );
  }

  Widget _buildLojasList(List<Loja> lojas) {
    return ListView.builder(
      itemCount: lojas.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final loja = lojas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  loja.capa,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48));
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loja.nome,
                        style: AppTheme.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            Routes.LOJA_AVALIACOES,
                            arguments: loja.id,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: AppTheme.accentColor, size: 20),
                            const SizedBox(width: 4),
                            Text(loja.nota.toString(), style: AppTheme.ratingStyle),
                            const SizedBox(width: 8),
                            Text('• ${loja.categoria.name}', style: AppTheme.cardSubtitle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
