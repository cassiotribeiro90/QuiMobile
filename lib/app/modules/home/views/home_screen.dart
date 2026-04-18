import 'package:flutter/material.dart';
import '../../lojas_list/views/lojas_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retornamos diretamente a LojasListScreen, que já possui seu próprio Scaffold e AppBar customizada
    return const LojasListScreen();
  }
}
