import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/loja_avaliacoes_cubit.dart';
import '../cubit/loja_avaliacoes_state.dart';

class LojaAvaliacoesView extends StatefulWidget {
  const LojaAvaliacoesView({super.key});

  @override
  State<LojaAvaliacoesView> createState() => _LojaAvaliacoesViewState();
}

class _LojaAvaliacoesViewState extends State<LojaAvaliacoesView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.read<LojaAvaliacoesCubit>().state is LojaAvaliacoesInitial) {
        context.read<LojaAvaliacoesCubit>().loadAvaliacoes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações da Loja'),
      ),
      body: BlocBuilder<LojaAvaliacoesCubit, LojaAvaliacoesState>(
        builder: (context, state) {
          if (state is LojaAvaliacoesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LojaAvaliacoesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(state.message, style: textTheme.bodyLarge, textAlign: TextAlign.center),
              ),
            );
          } else if (state is LojaAvaliacoesLoaded) {
            if (state.avaliacoes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Text('Esta loja ainda não tem avaliações.', style: textTheme.bodyLarge, textAlign: TextAlign.center),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.avaliacoes.length,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (context, index) {
                final avaliacao = state.avaliacoes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(avaliacao.nomeUsuario, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < avaliacao.nota ? Icons.star : Icons.star_border,
                                  color: colorScheme.secondary,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(avaliacao.comentario),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
