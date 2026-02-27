import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/loja_model.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/common/app_text.dart';
import '../cubit/lojas_cubit.dart';
import '../cubit/lojas_state.dart';

class LojasView extends StatefulWidget {
  const LojasView({super.key});

  @override
  State<LojasView> createState() => _LojasViewState();
}

class _LojasViewState extends State<LojasView> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Garante que o load só será chamado na primeira vez que o cubit for criado.
    if (context.read<LojasCubit>().state is LojasInitial) {
      context.read<LojasCubit>().loadLojas();
    }
  }

  Future<void> _onRefresh() async {
    context.read<LojasCubit>().loadLojas();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LojasCubit, LojasState>(
      listener: (context, state) {
        // Mostra o SnackBar em caso de erro, com verificação de montagem e ação de retry.
        if (state is LojasError && state is! LojasInitial) {
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  action: SnackBarAction(
                    label: 'Tentar Novamente',
                    onPressed: _onRefresh,
                  ),
                ),
              );
          }
        }
      },
      builder: (context, state) {
        // Mostra o loading apenas na carga inicial.
        if (state is LojasInitial || state is LojasLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Se houver um erro na carga inicial, mostra uma tela com botão de retry.
        if (state is LojasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  state.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                  margin: const EdgeInsets.symmetric(horizontal: 18.0),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: const Text('Tentar Novamente'),
                )
              ],
            ),
          );
        }

        if (state is LojasLoaded) {
          if (state.lojas.isEmpty) {
            return Center(
              child: AppText(
                'Nenhuma loja encontrada na sua região.',
                style: Theme.of(context).textTheme.bodyLarge,
                margin: const EdgeInsets.symmetric(horizontal: 18.0),
              ),
            );
          }
          // A lista é envolvida no RefreshIndicator e usa o _buildLojasList
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: _buildLojasList(state.lojas),
          );
        }

        // Retorna um container vazio para qualquer outro caso inesperado.
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLojasList(List<Loja> lojas) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Usando ListView.separated para melhor performance e separação visual.
    return ListView.separated(
      itemCount: lojas.length,
      padding: const EdgeInsets.all(16.0), // Padding geral da lista.
      separatorBuilder: (context, index) => const SizedBox(height: 12), // Espaçamento entre os cards.
      itemBuilder: (context, index) {
        final loja = lojas[index];
        return Card(
          margin: EdgeInsets.zero, // Margem controlada pelo padding e separator.
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: loja.capa,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48)),
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
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          loja.nome,
                          style: textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Ver avaliações',
                              icon: Icon(Icons.star, color: colorScheme.secondary),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  Routes.LOJA_AVALIACOES,
                                  arguments: loja.id,
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 4),
                            AppText(loja.nota.toString(), style: textTheme.labelLarge),
                            const SizedBox(width: 8),
                            AppText('• ${loja.categoria.name}', style: textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
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
