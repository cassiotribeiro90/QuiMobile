import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../models/produto_model.dart';

abstract class IProdutoRepository {
  Future<List<Produto>> getProdutosByLojaId(int lojaId);
}

class ProdutoRepositoryMock implements IProdutoRepository {
  @override
  Future<List<Produto>> getProdutosByLojaId(int lojaId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simula delay

    final String jsonString = await rootBundle.loadString('lib/app/assets/data/produtos.json');
    final data = json.decode(jsonString);
    final List<dynamic> todosProdutos = data['produtos'];

    final produtosDaLoja = todosProdutos
        .where((produto) => produto['lojaId'] == lojaId)
        .map((produtoData) => Produto.fromJson(produtoData))
        .toList();

    return produtosDaLoja;
  }
}
