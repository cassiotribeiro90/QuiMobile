import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lojas_cubit.dart';
import '../bloc/lojas_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/qui_card.dart';
import '../../../routes/app_routes.dart';

class LojasListScreen extends StatefulWidget {
  const LojasListScreen({super.key});

  @override
  State<LojasListScreen> createState() => _LojasListScreenState();
}

class _LojasListScreenState extends State<LojasListScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<LojasCubit>().fetchLojas(perPage: 10);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<LojasCubit>();
      final state = cubit.state;
      if (cubit.hasMorePages && state is LojasLoaded && !state.isLoadingMore) {
        cubit.fetchLojas(
          page: cubit.currentPage + 1,
          perPage: 10,
          isLoadMore: true,
        );
      }
    }
  }

  void _showFilter(LojasLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        categorias: state.categorias.map((c) => CategoriaFilter(
          label: c.label,
          value: c.value,
        )).toList(),
        selectedCategoria: state.categoriaSelecionada,
        onApply: (val) {
          context.read<LojasCubit>().filterByCategoria(val);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LojasCubit, LojasState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lojas'),
            actions: [
              if (state is LojasLoaded)
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.filter_list),
                      if (state.categoriaSelecionada != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => _showFilter(state),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar lojas...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => context.read<LojasCubit>().searchLojas(value),
                ),
              ),
            ),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(LojasState state) {
    if (state is LojasLoading) {
      return _buildLoadingState();
    }

    if (state is LojasLoaded) {
      final lojas = state.lojasFiltradas;
      if (lojas.isEmpty) return _buildEmptyState(state.lojas.isEmpty);

      return RefreshIndicator(
        onRefresh: () => context.read<LojasCubit>().refreshList(),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: lojas.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == lojas.length) {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            }
            return _LojaCard(loja: lojas[index]);
          },
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 12), child: LoadingSkeleton(height: 100)),
    );
  }

  Widget _buildEmptyState(bool isOverallEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Nenhuma loja encontrada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(isOverallEmpty ? 'Volte mais tarde!' : 'Tente outros filtros'),
        ],
      ),
    );
  }
}

class _LojaCard extends StatelessWidget {
  final dynamic loja;
  const _LojaCard({required this.loja});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: QuiCard(
        onTap: () => Navigator.pushNamed(context, Routes.lojaHome, arguments: loja.id),
        child: Row(
          children: [
            _buildLogo(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loja.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${loja.categoria} • ${loja.cidade}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(' ${loja.notaMedia} ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Expanded(
                        child: Text(
                          '• ${loja.tempoEntregaMin}-${loja.tempoEntregaMax} min • ${loja.taxaEntrega == 0 ? "Grátis" : "R\$ ${loja.taxaEntrega.toStringAsFixed(2)}"}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: (loja.logo != null) 
          ? Image.network(loja.logo!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.store))
          : const Center(child: Icon(Icons.store, color: Colors.grey)),
      ),
    );
  }
}
