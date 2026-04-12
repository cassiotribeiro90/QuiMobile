import 'package:flutter/material.dart';
import '../../lojas_list/views/lojas_list_screen.dart';
import '../../../widgets/app_drawer.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuiPede'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, Routes.carrinho),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const LojasListScreen(),
    );
  }
}
