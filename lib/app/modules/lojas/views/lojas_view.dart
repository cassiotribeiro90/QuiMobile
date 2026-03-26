import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/common/app_text.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../models/loja.dart';
import 'loja_item_widget.dart';

class LojasView extends StatefulWidget {
  const LojasView({super.key});

  @override
  State<LojasView> createState() => _LojasViewState();
}

class _LojasViewState extends State<LojasView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<LojasCubit>();
    if (cubit.state is LojasInitial) {
      cubit.fetchLojas();
    }
  }

  Future<void> _onRefresh() async {
    context.read<LojasCubit>().fetchLojas(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LojasCubit, LojasState>(
      listener: (context, state) {
        if (state is LojasError) {
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
          if (state.lojas.isEmpty) {
            return Center(
              child: AppText(
                'Nenhuma loja encontrada na sua região.',
                style: Theme.of(context).textTheme.bodyLarge,
                margin: const EdgeInsets.symmetric(horizontal: 18.0),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: _buildLojasList(state.lojas),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLojasList(List<Loja> lojas) {
    return ListView.separated(
      itemCount: lojas.length,
      padding: const EdgeInsets.all(4.0),
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return LojaItemWidget(loja: lojas[index]);
      },
    );
  }
}
