import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/common/app_text.dart';
import '../../lojas/cubit/lojas_cubit.dart';
import '../../lojas/views/lojas_view.dart';
import '../cubit/home_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  final List<Widget> _widgetOptions = const <Widget>[
    BlocProvider(
      create: _createLojasCubit,
      child: LojasView(),
    ),
    Center(
      child: AppText('Página de Perfil'),
    ),
  ];

  static LojasCubit _createLojasCubit(BuildContext context) {
    return LojasCubit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final currentIndex = state is HomeTabChanged ? state.selectedIndex : 0;

        return Scaffold(
          appBar: AppBar(
            title: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  context.read<HomeCubit>().changeTab(0);
                },
                // A SOLUÇÃO DEFINITIVA: Usar um Text simples, não o AppText que usa SelectableText.
                child: const Text('Qui Delivery'),
              ),
            ),
          ),
          body: IndexedStack(
            index: currentIndex,
            children: _widgetOptions,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<HomeCubit>().changeTab(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'Lojas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}
