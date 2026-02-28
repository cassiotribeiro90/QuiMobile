import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/loja_model.dart';
import '../../../widgets/common/app_text.dart';
import '../cubit/lojas_cubit.dart';
import '../cubit/lojas_state.dart';
import '../widgets/filtros_bar.dart';
import 'loja_item_widget.dart';

class LojaView extends StatefulWidget {
  const LojaView({super.key});

  @override
  State<LojaView> createState() => _LojaViewState();
}

class _LojaViewState extends State<LojaView> {

  @override
  void initState() {
    super.initState();
    if (context.read<LojasCubit>().state is LojasInitial) {
      context.read<LojasCubit>().loadLojas();
    }
  }

  Future<void> _onRefresh() async {
    context.read<LojasCubit>().loadLojas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const FiltrosBar(),
          const Divider(height: 1),
          Expanded(
            child: BlocConsumer<LojasCubit, LojasState>(
              listener: (context, state) {
                if (state is LojasError) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          action: SnackBarAction(label: 'Tentar Novamente', onPressed: _onRefresh),
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
                  return _buildErrorState();
                }

                if (state is LojasLoaded) {
                  return _buildLoadedState(state.filteredLojas);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Ocorreu um erro ao carregar as lojas.'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _onRefresh, child: const Text('Tentar Novamente')),
        ],
      ),
    );
  }

  Widget _buildLoadedState(List<Loja> lojas) {
    final listContent = lojas.isEmpty
        ? const Center(child: Text('Nenhuma loja encontrada com os filtros selecionados.'))
        : ListView.separated(
            itemCount: lojas.length,
            padding: const EdgeInsets.all(16.0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => LojaItemWidget(loja: lojas[index]),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Se for tela larga (web), centraliza a lista com largura máxima.
        if (constraints.maxWidth > 800) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: listContent,
            ),
          );
        }
        // No mobile, a lista ocupa toda a largura.
        return listContent;
      },
    );
  }
}
