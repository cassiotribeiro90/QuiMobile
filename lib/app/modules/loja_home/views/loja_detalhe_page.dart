import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../bloc/loja_home_cubit.dart';
import '../bloc/loja_home_state.dart';
import '../widgets/loja_header_widget.dart';
import '../widgets/search_with_filters.dart';
import '../widgets/produtos_list_widget.dart';
import '../../../core/theme/app_theme_extension.dart';

class LojaDetalhePage extends StatefulWidget {
  final int lojaId;

  const LojaDetalhePage({super.key, required this.lojaId});

  @override
  State<LojaDetalhePage> createState() => _LojaDetalhePageState();
}

class _LojaDetalhePageState extends State<LojaDetalhePage> {
  late final LojaHomeCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LojaHomeCubit>(param1: widget.lojaId)..loadLoja();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: BlocConsumer<LojaHomeCubit, LojaHomeState>(
          listener: (context, state) {
            if (state is LojaHomeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is LojaHomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LojaHomeError && state is! LojaHomeLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: context.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _cubit.loadLoja(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (state is LojaHomeLoaded) {
              final isLoadingMore = state.isLoadingMore;

              return RefreshIndicator(
                onRefresh: () => _cubit.refresh(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: context.surfaceColor,
                      elevation: 0,
                      leading: BackButton(color: context.textPrimary),
                      title: Text(
                        state.loja.nome,
                        style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.shopping_cart_outlined),
                          color: context.textPrimary,
                        ),
                      ],
                    ),
                    LojaHeaderWidget(loja: state.loja),
                    SliverToBoxAdapter(
                      child: SearchWithFilters(
                        categorias: state.loja.filterOptions.categorias,
                        selectedCategoriaId: state.selectedCategories.isNotEmpty ? state.selectedCategories.first : null,
                        selectedOrderBy: state.orderBy,
                        searchQuery: state.searchQuery,
                        onApply: (search, catId, orderBy) => _cubit.applyFilters(
                          search: search,
                          categoriaId: catId,
                          orderBy: orderBy,
                        ),
                        onClearFilters: () => _cubit.clearFilters(),
                      ),
                    ),
                    ProdutosListWidget(
                      items: state.produtos,
                      hasMore: state.hasMore,
                      isLoadingMore: isLoadingMore,
                      onLoadMore: () => _cubit.loadMore(),
                      onProdutoTap: (produto) {
                        Navigator.pushNamed(
                          context,
                          '/produto/detalhe',
                          arguments: {
                            'id': produto.id,
                            'produto': produto,
                          },
                        );
                      },
                    ),
                    if (isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
