import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_cubit.dart';
import '../../lojas/views/lojas_view.dart';
import '../../perfil/views/perfil_screen.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final currentIndex = state is HomeTabChanged ? state.selectedIndex : 0;

          return Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: const [
                LojasView(),
                Center(child: Text('Mapa - Em breve')),
                PerfilScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                context.read<HomeCubit>().changeTab(index);
              },
            ),
          );
        },
      ),
    );
  }
}
