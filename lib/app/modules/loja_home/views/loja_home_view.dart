import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/produto_model.dart';
import '../../../theme/app_theme.dart';
import '../cubit/loja_home_cubit.dart';
import '../cubit/loja_home_state.dart';

class LojaHomeView extends StatefulWidget {
  const LojaHomeView({super.key});

  @override
  State<LojaHomeView> createState() => _LojaHomeViewState();
}

class _LojaHomeViewState extends State<LojaHomeView> {
  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Mostra o header quando o usuário rola para cima (scrollOffset <= 0)
    // Esconde quando rola para baixo (scrollOffset > 50)
    final shouldShow = _scrollController.offset <= 50;

    if (_showHeader != shouldShow) {
      setState(() {
        _showHeader = shouldShow;
      });
    }
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
              controller: _scrollController,
              slivers: [
                // SLIVER APPBAR - Header que aparece/desaparece com scroll
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: false,
                  floating: true,
                  snap: true,
                  stretch: true,
                  backgroundColor: Colors.white,
                  elevation: _showHeader ? 0 : 4,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: _showHeader ? Colors.white : AppTheme.primaryColor,
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showHeader ? 0 : 1,
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

                        // Gradiente para legibilidade
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),

                        // Informações da loja
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              // Logo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: loja.logo,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.store),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Nome e status
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loja.nome,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          loja.nota.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: loja.isOpenNow
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            loja.isOpenNow ? 'Aberto' : 'Fechado',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
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
              // Título da categoria
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  categoria,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Lista de produtos
              ...produtos.map((produto) => _buildProdutoItem(context, produto)),

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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nome,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  if (produto.descricao.isNotEmpty)
                    Text(
                      produto.descricao,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
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
                        const SizedBox(width: 8),
                      ],
                      Text(
                        produto.emPromocao
                            ? produto.precoPromocionalFormatado
                            : produto.precoFormatado,
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
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}