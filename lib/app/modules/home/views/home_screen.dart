import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/theme_cubit.dart';
import '../../../../features/auth/bloc/auth_cubit.dart';
import '../../../../features/loja/bloc/loja_cubit.dart';
import '../../../../features/loja/bloc/loja_state.dart';
import '../../../../features/auth/bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LojaCubit>().listarLojas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuiPede'),
        actions: [
          // Botão de alternar tema
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == ThemeMode.dark 
                      ? Icons.light_mode_outlined 
                      : Icons.dark_mode_outlined,
                ),
                tooltip: 'Alternar tema',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF3949AB)),
              child: Text('Menu QuiPede', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Lojas'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Criar Nova Loja'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/criar-loja');
              },
            ),
          ],
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: BlocBuilder<LojaCubit, LojaState>(
          builder: (context, state) {
            if (state is LojaLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LojasLoaded) {
              return RefreshIndicator(
                onRefresh: () => context.read<LojaCubit>().listarLojas(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.lojas.length,
                  itemBuilder: (context, index) {
                    final loja = state.lojas[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.store)),
                        title: Text(loja['nome'] ?? 'Sem nome'),
                        subtitle: Text(loja['cnpj'] ?? 'Sem CNPJ'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    );
                  },
                ),
              );
            }
            return const Center(child: Text('Bem-vindo ao QuiPede'));
          },
        ),
      ),
    );
  }
}
