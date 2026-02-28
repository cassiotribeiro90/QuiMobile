import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../../lojas/widgets/product_card.dart';
import '../cubit/loja_home_cubit.dart';
import '../cubit/loja_home_state.dart';
import 'filter_modal.dart';

class LojaHomeView extends StatefulWidget {
  const LojaHomeView({super.key});

  @override
  State<LojaHomeView> createState() => _LojaHomeViewState();
}

class _LojaHomeViewState extends State<LojaHomeView> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchController.addListener(() {
      context.read<LojaHomeCubit>().searchQueryChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showFilterModal(LojaHomeLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<LojaHomeCubit>(),
        child: FilterModal(
          // CORRIGIDO: Passa os valores do estado atual
          selectedCategories: state.selectedCategories,
          priceRange: const RangeValues(0, 100), // Exemplo, idealmente viria do state
          onApply: (selectedCategories, priceRange) {
            context.read<LojaHomeCubit>().applyCategoryFilter(selectedCategories);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LojaHomeCubit, LojaHomeState>(
        builder: (context, state) {
          if (state is LojaHomeLoading || state is LojaHomeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LojaHomeError) {
            return Center(child: Text(state.message));
          } else if (state is LojaHomeLoaded) {
            final loja = state.loja;

            return GestureDetector(
              onTap: () => _searchFocusNode.unfocus(),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220.0,
                    pinned: true,
                    backgroundColor: AppTheme.primaryColor,
                    title: Text(loja.nome),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(imageUrl: loja.capa, fit: BoxFit.cover),
                          Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.topCenter, end: Alignment.center))),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SearchHeaderDelegate(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onFilterTap: () => _showFilterModal(state), // Passa o estado atual
                      selectedFiltersCount: state.activeFilterCount,
                    ),
                  ),
                  _buildBody(context, state),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LojaHomeLoaded state) {
    if (state.filteredProdutos.isEmpty && _searchController.text.isNotEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('Nenhum produto encontrado para sua busca.')));
    }
    if (state.filteredProdutos.isEmpty && state.activeFilterCount > 0) {
      return const SliverFillRemaining(child: Center(child: Text('Nenhum produto encontrado com os filtros selecionados.')));
    }

    final categorias = state.produtosPorCategoria.keys.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final categoria = categorias[index];
          final produtosDaCategoria = state.produtosPorCategoria[categoria] ?? [];
          if (produtosDaCategoria.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(categoria, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 24),
                ...produtosDaCategoria.map((produto) => ProductCard(produto: produto)),
              ],
            ),
          );
        },
        childCount: categorias.length,
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilterTap;
  final int selectedFiltersCount;

  _SearchHeaderDelegate({
    required this.controller,
    required this.focusNode,
    required this.onFilterTap,
    required this.selectedFiltersCount,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(hintText: 'Buscar no cardápio...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 15)),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    IconButton(icon: const Icon(Icons.clear, size: 18, color: Colors.grey), onPressed: () => controller.clear(), padding: EdgeInsets.zero),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48, height: 48, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                child: IconButton(icon: const Icon(Icons.tune, color: AppTheme.primaryColor), onPressed: onFilterTap, padding: EdgeInsets.zero),
              ),
              if (selectedFiltersCount > 0)
                Positioned(
                  top: -4, right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(selectedFiltersCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) {
    return oldDelegate.selectedFiltersCount != selectedFiltersCount || oldDelegate.controller.text != controller.text;
  }
}
