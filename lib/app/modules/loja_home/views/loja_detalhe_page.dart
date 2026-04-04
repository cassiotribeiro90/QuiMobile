import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../bloc/loja_home_cubit.dart';
import '../bloc/loja_home_state.dart';
import '../widgets/loja_header_widget.dart';
import '../widgets/search_with_filters.dart';
import '../widgets/secoes_list_widget.dart';
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
            // ===== PRIMEIRO CARREGAMENTO (tela inteira) =====
            if (state is LojaHomeLoading && state.secoes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // ===== ERRO (sem dados) =====
            if (state is LojaHomeError && state.secoes.isEmpty) {
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

            // ===== ESTADO CARREGADO (ou com dados parciais) =====
            if (state is LojaHomeLoaded || state.loja != null) {
              final loadedState = state is LojaHomeLoaded ? state : null;
              final loja = state.loja;
              
              // Verifica se estamos filtrando (reset de lista com dados prévios)
              final isFiltering = loadedState?.isFiltering ?? false;
              // Verifica se estamos paginando (scroll infinito)
              final isLoadingMore = loadedState?.isLoadingMore ?? (state is LojaHomeLoadingMore);
              
              final hasData = state.secoes.isNotEmpty;

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => _cubit.refresh(),
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // AppBar
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: context.surfaceColor,
                          elevation: 0,
                          leading: BackButton(color: context.textPrimary),
                          title: Text(
                            loja?.nome ?? 'Carregando...',
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
                        
                        // Header da loja (sempre visível)
                        if (loja != null) LojaHeaderWidget(loja: loja),
                        
                        // Barra de pesquisa e filtros
                        if (loja != null)
                          SliverToBoxAdapter(
                            child: SearchWithFilters(
                              categorias: loja.filterOptions.categorias,
                              selectedCategoriaId: loadedState?.selectedCategories.isNotEmpty == true 
                                  ? loadedState!.selectedCategories.first 
                                  : null,
                              selectedOrderBy: loadedState?.orderBy,
                              searchQuery: loadedState?.searchQuery,
                              onApply: (search, catId, orderBy) => _cubit.applyFilters(
                                search: search,
                                categoriaId: catId,
                                orderBy: orderBy,
                              ),
                              onClearFilters: () => _cubit.clearFilters(),
                            ),
                          ),
                        
                        // Indicador sutil para paginação
                        if (isLoadingMore && hasData)
                          const SliverToBoxAdapter(
                            child: LinearProgressIndicator(minHeight: 2),
                          ),

                        // ===== LISTA DE PRODUTOS =====
                        SecoesListWidget(
                          secoes: state.secoes,
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
                        
                        // Mensagem de fim de lista
                        if (loadedState != null && !loadedState.hasMore && state.secoes.isNotEmpty && !isFiltering)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  'Isso é tudo por enquanto! 🍕',
                                  style: context.bodySmall.copyWith(color: context.textHint),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // ✅ OVERLAY SEMI-TRANSPARENTE DURANTE FILTROS (Alpha aumentado para ficar mais visível)
                  if (isFiltering)
                    Container(
                      color: Colors.white.withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
