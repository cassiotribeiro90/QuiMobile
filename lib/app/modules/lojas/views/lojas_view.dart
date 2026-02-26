import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/loja_model.dart';
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
    // O próprio módulo de lojas agora é responsável por carregar seus dados
    context.read<LojasCubit>().loadLojas();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        if (state is LojasLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LojasError) {
          return Center(child: Text(state.message));
        } else if (state is LojasLoaded) {
          return _buildLojasList(state.lojas);
        } else {
          return const Center(child: Text('Nenhuma loja encontrada.'));
        }
      },
    );
  }

  Widget _buildLojasList(List<Loja> lojas) {
    return ListView.builder(
      itemCount: lojas.length,
      itemBuilder: (context, index) {
        final loja = lojas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                loja.capa,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loja.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(loja.nota.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('• ${loja.categoria}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
