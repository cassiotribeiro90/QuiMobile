import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../shared/api/api_client.dart';
import '../../../models/carrinho_response.dart';
import '../../../models/verificacao_loja_response.dart';
import '../../../models/carrinho_result.dart';

class CarrinhoService {
  final ApiClient _apiClient;

  CarrinhoService(this._apiClient);

  // ✅ ÚNICO método para adicionar/atualizar/remover
  Future<CarrinhoResult> atualizarItem({
    int? itemId,      // Para atualizar/remover item existente
    int? produtoId,   // Para adicionar novo item
    int quantidade = 1,
    List<int> opcoes = const [],
    String? observacao,
  }) async {
    try {
      final Map<String, dynamic> data = {'quantidade': quantidade};
      
      if (itemId != null) data['item_id'] = itemId;
      if (produtoId != null) data['produto_id'] = produtoId;
      if (opcoes.isNotEmpty) data['opcoes'] = opcoes;
      if (observacao != null && observacao.isNotEmpty) data['observacao'] = observacao;

      if (kDebugMode) {
        print('📤 [CarrinhoService] Enviando: $data');
      }

      final response = await _apiClient.put('app/carrinho/atualizar', data: data);
      
      if (kDebugMode) {
        print('✅ [CarrinhoService] Sucesso: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final resData = CarrinhoResponse.fromJson(response.data['data']);
        return CarrinhoResult.success(resData);
      }else if(response.statusCode == 409){
        if (kDebugMode) print('⚠️ [CarrinhoService] 409 detectado - Conflito de loja');
        final json = response.data;
        if (json != null) {
          return CarrinhoResult.conflito(CarrinhoConflito.fromJson(json));
        }
      }

      final error = response.statusCode.toString();
      return CarrinhoResult.error(error);

    } on DioException catch (e) {
      if (kDebugMode) print('❌ [CarrinhoService] Erro Dio: $e');
      return CarrinhoResult.error(e.message ?? 'Erro na requisição', code: e.response?.statusCode);
    } catch (e) {
      if (kDebugMode) print('❌ [CarrinhoService] Erro inesperado: $e');
      return CarrinhoResult.error(e.toString());
    }
  }

  /// Verifica se o carrinho atual é de uma loja específica
  Future<VerificacaoLojaResponse> verificarLoja(int lojaId) async {
    try {
      final response = await _apiClient.get('app/carrinho/verificar-loja', 
        queryParameters: {'loja_id': lojaId}
      );
      return VerificacaoLojaResponse.fromJson(response.data['data']);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao verificar loja: $e');
      rethrow;
    }
  }

  Future<CarrinhoResponse> carregarCarrinho() async {
    final response = await _apiClient.get('app/carrinho');
    return CarrinhoResponse.fromJson(response.data['data']);
  }

  Future<void> limparCarrinho() async {
    await _apiClient.post('app/carrinho/limpar');
  }
}
