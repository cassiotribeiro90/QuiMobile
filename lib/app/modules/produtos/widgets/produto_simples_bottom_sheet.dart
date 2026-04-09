// lib/modules/produtos/widgets/produto_simples_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';
import '../../auth/views/login_screen.dart';

class ProdutoSimplesBottomSheet extends StatefulWidget {
  final dynamic produto;
  final int lojaId;

  const ProdutoSimplesBottomSheet({
    super.key,
    required this.produto,
    required this.lojaId,
  });

  @override
  State<ProdutoSimplesBottomSheet> createState() => _ProdutoSimplesBottomSheetState();
}

class _ProdutoSimplesBottomSheetState extends State<ProdutoSimplesBottomSheet> {
  int _quantidade = 1;
  bool _isLoading = false;
  final TextEditingController _observacaoController = TextEditingController();

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;
    final precoTotal = produto.preco * _quantidade;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle de arrastar
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

            // Conteúdo do produto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem e informações básicas
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (produto.imagem != null)
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
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produto.nome,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${produto.preco.toStringAsFixed(2)}',
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
                  ),

                  if (produto.descricao != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      produto.descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Observação
                  TextField(
                    controller: _observacaoController,
                    decoration: InputDecoration(
                      hintText: 'Alguma observação?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 20),

                  // Quantidade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantidade',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _quantidade > 1
                                ? () => setState(() => _quantidade--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_quantidade',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _quantidade++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botão Adicionar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAdicionar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        'Adicionar • R\$ ${precoTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAdicionar() async {
    // ✅ 1. Verificar autenticação
    final authCubit = getIt<AuthCubit>();
    final authState = authCubit.state;

    if (authState is! AuthAuthenticated) {
      // Fecha o bottom sheet
      Navigator.pop(context);

      // ✅ Mostra SnackBar com ação de login
      _mostrarSnackBarLogin();
      return;
    }

    // ✅ 2. Usuário autenticado, prossegue com adição
    setState(() => _isLoading = true);

    try {
      final carrinhoCubit = context.read<CarrinhoCubit>();
      final sucesso = await carrinhoCubit.adicionarItemSimples(
        produtoId: widget.produto.id,
        lojaId: widget.lojaId,
        nome: widget.produto.nome,
        imagem: widget.produto.imagem,
        preco: widget.produto.preco,
        quantidade: _quantidade,
      );

      if (sucesso && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.produto.nome} adicionado ao carrinho!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao adicionar item ao carrinho'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnackBarLogin() {
    // ✅ SnackBar nativo com ação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Faça login para adicionar itens'),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'LOGIN',
          textColor: Colors.white,
          onPressed: () {
            // ✅ Abre a tela de login diretamente
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ).then((_) {
              // ✅ Após voltar do login, verifica se autenticou
              final authCubit = getIt<AuthCubit>();
              if (authCubit.state is AuthAuthenticated) {
                // Se autenticou, reabre o bottom sheet automaticamente
                _abrirBottomSheetNovamente();
              }
            });
          },
        ),
      ),
    );
  }

  void _abrirBottomSheetNovamente() {
    // Pequeno delay para garantir que o contexto está pronto
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BlocProvider.value(
            value: getIt<CarrinhoCubit>(),
            child: ProdutoSimplesBottomSheet(
              produto: widget.produto,
              lojaId: widget.lojaId,
            ),
          ),
        );
      }
    });
  }
}