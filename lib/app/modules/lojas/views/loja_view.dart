import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/loja_model.dart';
import '../../../widgets/common/app_text.dart';
import '../cubit/lojas_cubit.dart';
import '../cubit/lojas_state.dart';
import '../widgets/filtros_bar.dart';
import 'loja_item_widget.dart';

// CORRIGIDO: Convertido para StatefulWidget
class LojaView extends StatefulWidget {
  const LojaView({super.key});

  @override
  State<LojaView> createState() => _LojaViewState();
}

class _LojaViewState extends State<LojaView> {

  @override
  void initState() {
    super.initState();
    // Carrega os dados apenas se o cubit estiver no estado inicial.
    if (context.read<LojasCubit>().state is LojasInitial) {
      context.read<LojasCubit>().loadLojas();
    }
  }

  Future<void> _onRefresh() async {
    context.read<LojasCubit>().loadLojas();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FiltrosBar(),
        Expanded(
          child: BlocConsumer<LojasCubit, LojasState>(
            listener: (context, state) {
              if (state is LojasError) {
                // CORRIGIDO: A verificação 'mounted' agora é válida.
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
              if (state is LojasInitial || state is LojasLoading) {
                return const Center(child: CircularProgressIndicator());
              }

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
                if (state.filteredLojas.isEmpty) {
                  return Center(
                    child: AppText(
                      'Nenhuma loja encontrada com os filtros selecionados.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      margin: const EdgeInsets.symmetric(horizontal: 18.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _buildLojasList(state.filteredLojas),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLojasList(List<Loja> lojas) {
    return ListView.separated(
      itemCount: lojas.length,
      padding: const EdgeInsets.all(16.0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return LojaItemWidget(loja: lojas[index]);
      },
    );
  }
}
