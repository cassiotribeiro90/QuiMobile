// lib/modules/carrinho/services/carrinho_service.dart

import 'package:flutter/foundation.dart';
import '../../../../shared/api/api_client.dart';
import '../../../models/carrinho_response.dart';

class CarrinhoService {
  final ApiClient _apiClient;

  CarrinhoService(this._apiClient);

  Future<CarrinhoResponse> adicionarItem({
    required int produtoId,
    required int quantidade,
    List<int> opcoes = const [],
    String? observacao,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'produto_id': produtoId,
        'quantidade': quantidade,
      };

      if (opcoes.isNotEmpty) {
        data['opcoes'] = opcoes;
      }

      if (observacao != null && observacao.isNotEmpty) {
        data['observacao'] = observacao;
      }

      final response = await _apiClient.post('app/carrinho/adicionar', data: data);
      return CarrinhoResponse.fromJson(response.data['data']);
    } catch (e) {
      if (kDebugMode) print('❌ Erro no CarrinhoService (adicionar): $e');
      rethrow;
    }
  }

  // ✅ CORRIGIDO: Agora recebe itemId (ID do item no carrinho)
  Future<CarrinhoResponse> atualizarQuantidade({
    required int itemId, // Mudou de produtoId para itemId
    required int quantidade,
  }) async {
    try {
      final response = await _apiClient.put('app/carrinho/atualizar', data: {
        'item_id': itemId, // ✅ Mudou de produto_id para item_id
        'quantidade': quantidade,
      });
      return CarrinhoResponse.fromJson(response.data['data']);
    } catch (e) {
      if (kDebugMode) print('❌ Erro no CarrinhoService (atualizar): $e');
      rethrow;
    }
  }

  Future<CarrinhoResponse> removerItem({required int itemId}) async {
    try {
      final response = await _apiClient.post('app/carrinho/remover', data: {
        'item_id': itemId, // ✅ Já estava correto
      });
      return CarrinhoResponse.fromJson(response.data['data']);
    } catch (e) {
      if (kDebugMode) print('❌ Erro no CarrinhoService (remover): $e');
      rethrow;
    }
  }

  Future<CarrinhoResponse> carregarCarrinho() async {
    try {
      final response = await _apiClient.get('app/carrinho/index');

      if (kDebugMode) {
        print('✅ Carrinho carregado com sucesso');
      }

      return CarrinhoResponse.fromJson(response.data['data']);
    } catch (e) {
      if (kDebugMode) print('❌ Erro no CarrinhoService (index): $e');
      rethrow;
    }
  }
}