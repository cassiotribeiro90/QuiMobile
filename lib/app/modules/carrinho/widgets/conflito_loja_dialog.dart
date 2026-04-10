import 'package:flutter/material.dart';

class ConflitoLojaDialog extends StatelessWidget {
  final String lojaAtualNome;
  final VoidCallback onLimpar;
  final VoidCallback onCancelar;

  const ConflitoLojaDialog({
    super.key,
    required this.lojaAtualNome,
    required this.onLimpar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Carrinho de outra loja'),
      content: Text(
        'Seu carrinho já contém itens de "$lojaAtualNome". '
        'Deseja limpar o carrinho e adicionar itens desta nova loja?'
      ),
      actions: [
        TextButton(
          onPressed: onCancelar,
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: onLimpar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Limpar e Adicionar'),
        ),
      ],
    );
  }
}
