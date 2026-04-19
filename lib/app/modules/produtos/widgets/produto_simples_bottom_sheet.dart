import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';

class ProdutoSimplesBottomSheet extends StatefulWidget {
  final dynamic produto;
  final int lojaId;
  final int? itemId;
  final int? initialQuantidade;
  final String? initialObservacao;

  const ProdutoSimplesBottomSheet({
    super.key,
    required this.produto,
    required this.lojaId,
    this.itemId,
    this.initialQuantidade,
    this.initialObservacao,
  });

  @override
  State<ProdutoSimplesBottomSheet> createState() => _ProdutoSimplesBottomSheetState();
}

class _ProdutoSimplesBottomSheetState extends State<ProdutoSimplesBottomSheet> {
  late int _quantidade;
  bool _isAdding = false;
  late final TextEditingController _observacaoController;

  @override
  void initState() {
    super.initState();
    _quantidade = widget.initialQuantidade ?? 1;
    _observacaoController = TextEditingController(text: widget.initialObservacao);
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdicao = widget.itemId != null;

    return BlocListener<CarrinhoCubit, CarrinhoState>(
      listener: (context, state) {
        if (kDebugMode) {
          print('📥 [ProdutoModal] Novo estado recebido: ${state.runtimeType}');
        }

        if (state is CarrinhoConflitoLoja) {
          setState(() => _isAdding = false);
          _mostrarDialogoConflito(state);
        } else if (state is CarrinhoLoaded && _isAdding) {
          setState(() => _isAdding = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdicao 
                ? '${widget.produto.nome} atualizado!' 
                : '${widget.produto.nome} adicionado ao carrinho!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CarrinhoError && _isAdding) {
          setState(() => _isAdding = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), 
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProdutoHeader(),
                    if (widget.produto.descricao != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.produto.descricao,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextField(
                      controller: _observacaoController,
                      enabled: !_isAdding,
                      decoration: InputDecoration(
                        hintText: 'Alguma observação?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    _buildQuantidadeSelector(),
                    const SizedBox(height: 24),
                    _buildBotaoAcao(isEdicao),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProdutoHeader() {
    final produto = widget.produto;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (produto.imagem != null && produto.imagem.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              produto.imagem,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          )
        else
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                produto.nome ?? 'Produto',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'R\$ ${(produto.preco ?? 0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantidadeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quantidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Row(
          children: [
            IconButton(
              onPressed: _isAdding
                  ? null
                  : (_quantidade > 1
                      ? () => setState(() => _quantidade--)
                      : null),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$_quantidade', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              onPressed: _isAdding ? null : () => setState(() => _quantidade++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBotaoAcao(bool isEdicao) {
    final precoTotal = (widget.produto.preco ?? 0) * _quantidade;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isAdding ? null : _handleAcao,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: _isAdding
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : Text('${isEdicao ? 'Atualizar' : 'Adicionar'} • R\$ ${precoTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _handleAcao() async {
    final authCubit = getIt<AuthCubit>();
    if (authCubit.state is! AuthAuthenticated) {
      Navigator.pop(context, {
        'requestLogin': true,
        'produto': widget.produto,
        'lojaId': widget.lojaId,
        'quantidade': _quantidade,
        'observacao': _observacaoController.text.trim(),
      });
      return;
    }

    setState(() => _isAdding = true);

    final observacao = _observacaoController.text.trim().isNotEmpty
        ? _observacaoController.text.trim()
        : null;

    if (widget.itemId != null) {
      // ✅ Edição de item existente
      context.read<CarrinhoCubit>().adicionarItem(
        produtoId: widget.produto.id,
        quantidade: _quantidade,
        observacao: observacao,
        applyDebounce: false
      );
    } else {
      // ✅ Novo item
      context.read<CarrinhoCubit>().adicionarItem(
        produtoId: widget.produto.id,
        quantidade: _quantidade,
        observacao: observacao,
        applyDebounce: false
      );
    }
  }

  void _mostrarDialogoConflito(CarrinhoConflitoLoja conflito) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Carrinho br outra loja'),
        content: Text(conflito.mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isAdding = true);
              await context.read<CarrinhoCubit>().limparEAdicionar(
                produtoId: widget.produto.id,
                quantidade: _quantidade,
                observacao: _observacaoController.text.trim().isNotEmpty 
                    ? _observacaoController.text.trim() 
                    : null,
              );
            },
            child: const Text('Limpar e adicionar'),
          ),
        ],
      ),
    );
  }
}
