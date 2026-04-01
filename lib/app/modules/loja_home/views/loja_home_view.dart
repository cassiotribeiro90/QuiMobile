import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../../apparte/widgets/product_card.dart';
import '../bloc/loja_home_cubit.dart';
import '../bloc/loja_home_state.dart';
import '../views/filter_modal.dart';

class LojaHomeView extends StatefulWidget {
  const LojaHomeView({super.key});

  @override
  State<LojaHomeView> createState() => _LojaHomeViewState();
}

class _LojaHomeViewState extends State<LojaHomeView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isHeaderCollapsed = false;
  final ScrollController _scrollController = ScrollController();
  LojaHomeLoaded? _lastLoadedState;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LojaHomeCubit>().fetchLojaDetails();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isCollapsed = _scrollController.hasClients && _scrollController.offset > 200;
    if (_isHeaderCollapsed != isCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
    }
  }

  void _openFilterModal() {
    final cubit = context.read<LojaHomeCubit>();
    final state = cubit.state;
    
    // Pegamos os filtros do último estado carregado se o atual for Loading
    final currentLoaded = state is LojaHomeLoaded ? state : _lastLoadedState;
    if (currentLoaded == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        selectedCategories: Set.from(currentLoaded.selectedCategories),
        priceRange: const RangeValues(0, 150),
        onApply: (categories, range) {
          cubit.applyFilters(categories);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LojaHomeCubit, LojaHomeState>(
        listener: (context, state) {
          if (state is LojaHomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<LojaHomeCubit, LojaHomeState>(
          builder: (context, state) {
            if (state is LojaHomeLoaded) {
              _lastLoadedState = state;
            }

            if (_lastLoadedState == null && (state is LojaHomeLoading || state is LojaHomeInitial)) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LojaHomeError && _lastLoadedState == null) {
              return Center(child: Text(state.message));
            }

            // Usamos o último estado carregado para manter a UI estável durante a busca
            final loadedState = state is LojaHomeLoaded ? state : _lastLoadedState!;
            final loja = loadedState.loja;
            final isSearching = state is LojaHomeLoading;

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: _isHeaderCollapsed ? AppTheme.primaryColor : Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHeaderCollapsed ? 1.0 : 0.0,
                    child: Text(
                      loja.nome,
                      style: const TextStyle(
                        color: AppTheme.darkColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: loja.capa?.toString() ?? "",
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Container(color: AppTheme.lightGreyColor),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: loja.logo ?? "",
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.store),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      loja.nome,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          loja.notaMedia.toString(),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'ABERTO',
                                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchHeaderDelegate(
                    controller: _searchController,
                    searchText: _searchController.text,
                    focusNode: _searchFocus,
                    onFilterTap: _openFilterModal,
                    selectedFiltersCount: loadedState.activeFilterCount,
                    onChanged: (value) {
                      context.read<LojaHomeCubit>().searchQueryChanged(value);
                      setState(() {}); // Garante que o botão de limpar atualize
                    },
                  ),
                ),
                if (isSearching)
                  const SliverToBoxAdapter(
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: _buildProdutosSliver(context, loadedState),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProdutosSliver(BuildContext context, LojaHomeLoaded state) {
    final categorias = state.produtosPorCategoria.keys.toList();

    if (categorias.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text('Nenhum produto encontrado'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= categorias.length) {
            if (state.hasMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<LojaHomeCubit>().loadMoreProdutos();
              });
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox();
          }

          final categoria = categorias[index];
          final produtos = state.produtosPorCategoria[categoria]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: Text(
                  categoria,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              ...produtos.map((produto) => ProductCard(produto: produto)),
              if (index < categorias.length - 1) const Divider(height: 24),
            ],
          );
        },
        childCount: categorias.length + 1,
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final String searchText;
  final FocusNode focusNode;
  final VoidCallback onFilterTap;
  final int selectedFiltersCount;
  final Function(String)? onChanged;

  _SearchHeaderDelegate({
    required this.controller,
    required this.searchText,
    required this.focusNode,
    required this.onFilterTap,
    required this.selectedFiltersCount,
    this.onChanged,
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
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Buscar no cardápio...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        controller.clear();
                        if (onChanged != null) onChanged!('');
                      },
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: AppTheme.primaryColor),
                  onPressed: onFilterTap,
                  padding: EdgeInsets.zero,
                ),
              ),
              if (selectedFiltersCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      selectedFiltersCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
    return oldDelegate.selectedFiltersCount != selectedFiltersCount ||
        oldDelegate.searchText != searchText;
  }
}
