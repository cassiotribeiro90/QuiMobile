import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/produto_model.dart';
import '../../../theme/app_theme.dart';
import '../../apparte/widgets/product_card.dart';
import '../cubit/loja_home_cubit.dart';
import '../views/filter_modal.dart';
import '../views/loja_home_view.dart';
import 'loja_home_state.dart';


class _LojaHomeViewState extends State<LojaHomeView> {


  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isHeaderCollapsed = false;
  final ScrollController _scrollController = ScrollController();

  // Filtros selecionados (exemplo)
  final Set<String> _selectedCategories = {};
  final RangeValues _priceRange = const RangeValues(0, 150);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Verifica se o header está colapsado (scroll > expandedHeight)
    final isCollapsed = _scrollController.offset > 200; // Ajuste conforme necessidade

    if (_isHeaderCollapsed != isCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
    }
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        selectedCategories: _selectedCategories,
        priceRange: _priceRange,
        onApply: (categories, range) {
          setState(() {
            _selectedCategories.clear();
            _selectedCategories.addAll(categories);
            // Aplica os filtros aqui
          });
        },
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

            return CustomScrollView(
              slivers: [
                // SLIVER APPBAR COM HEADER
                SliverAppBar(
                  expandedHeight: 280,
                  floating: true,
                  snap: true,
                  pinned: false,
                  stretch: true,
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppTheme.primaryColor,
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
                        // Imagem de fundo
                        CachedNetworkImage(
                          imageUrl: loja.capa,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Container(color: AppTheme.lightGreyColor),
                        ),

                        // Gradiente
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

                        // Informações da loja
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
                                  imageUrl: loja.logo,
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
                                          loja.nota.toString(),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: loja.isOpenNow ? Colors.green : Colors.red,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            loja.isOpenNow ? 'ABERTO' : 'FECHADO',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

                // BARRA DE PESQUISA E FILTRO (FIXA)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchHeaderDelegate(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onFilterTap: _openFilterModal,
                    selectedFiltersCount: _selectedCategories.length,
                  ),
                ),

                // CONTEÚDO DOS PRODUTOS
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: _buildProdutosSliver(context, state.produtosPorCategoria),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProdutosSliver(
      BuildContext context,
      Map<String, List<Produto>> produtosPorCategoria,
      ) {
    final categorias = produtosPorCategoria.keys.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final categoria = categorias[index];
          final produtos = produtosPorCategoria[categoria]!;

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
        childCount: categorias.length,
      ),
    );
  }

  Widget _buildProdutoItem(BuildContext context, Produto produto) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (produto.descricao.isNotEmpty)
                    Text(
                      produto.descricao,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (produto.emPromocao) ...[
                        Text(
                          produto.precoFormatado,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          produto.precoPromocionalFormatado,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ] else
                        Text(
                          produto.precoFormatado,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (produto.imagem.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: produto.imagem,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.fastfood, color: Colors.grey[400]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// DELEGATE PARA HEADER PERSISTENTE (SEARCH + FILTRO)
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
          // Campo de busca expandido
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
                      onPressed: () => controller.clear(),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Botão de filtro com badge
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

              // Badge de contagem de filtros
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
        oldDelegate.controller.text != controller.text;
  }
}

