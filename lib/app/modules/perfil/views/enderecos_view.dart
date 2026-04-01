import 'package:flutter/material.dart';

class EnderecosView extends StatelessWidget {
  const EnderecosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Endereços')),
      body: const Center(child: Text('Nenhum endereço cadastrado')),
    );
  }
}
