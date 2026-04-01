import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qui/app/modules/auth/bloc/auth_cubit.dart';
import 'package:qui/app/modules/auth/bloc/auth_state.dart';
import 'package:qui/app/modules/home/bloc/home_cubit.dart';
import 'package:qui/app/modules/lojas/views/lojas_view.dart';
import 'package:qui/app/modules/perfil/views/perfil_view.dart';
import 'package:qui/app/modules/perfil/views/pedidos_view.dart';
import 'package:qui/app/widgets/app_drawer.dart';
import 'package:qui/app/widgets/home_app_bar.dart';
import 'package:qui/app/modules/lojas/widgets/filter_search_bottom_sheet.dart';
import 'package:qui/app/modules/lojas/bloc/lojas_cubit.dart';
import 'package:qui/app/core/theme/app_theme_extension.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            key: _scaffoldKey,
            appBar: _buildAppBar(currentIndex),
            drawer: AppDrawer(
              selectedIndex: currentIndex,
              onItemSelected: (index) {
                context.read<HomeCubit>().changeTab(index);
              },
            ),
            body: _buildBody(currentIndex),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int currentIndex) {
    if (currentIndex == 0) {
      return HomeAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onAddressTap: () {
          // Navegação de endereço já tratada no HomeAppBar para Routes.ENDERECOS
        },
        onSearchTap: () => _showFilterBottomSheet(context),
        onProfileTap: () => context.read<HomeCubit>().changeTab(2),
      );
    }

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, color: context.textPrimary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(_getPageTitle(currentIndex), style: context.titleSmall),
    );
  }

  Widget _buildBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const LojasView();
      case 1:
        return const PedidosView();
      case 2:
        return const PerfilView();
      default:
        return const LojasView();
    }
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Lojas';
      case 1:
        return 'Meus Pedidos';
      case 2:
        return 'Perfil';
      case 3:
        return 'Configurações';
      default:
        return '';
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<LojasCubit>(),
        child: FilterSearchBottomSheet(
          onApplyFilters: (search, categoria, ordenacao) {
            context.read<LojasCubit>().applyFilters(
              search: search,
              categoria: categoria,
              ordenacao: ordenacao,
            );
          },
        ),
      ),
    );
  }
}
