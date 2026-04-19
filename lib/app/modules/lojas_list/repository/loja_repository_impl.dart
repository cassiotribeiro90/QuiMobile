import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../shared/api/api_client.dart';
import '../../../models/loja_resumo_model.dart';
import '../../../models/loja_resumo_response_model.dart';
import '../../../models/enums.dart';
import 'loja_repository.dart';

class LojaRepositoryImpl implements LojaRepository {
  final ApiClient _apiClient;

  LojaRepositoryImpl(this._apiClient);

  @override
  Future<LojaResumoResponseModel> getLojas({
    int page = 1,
    int perPage = 10,
    String? categoria,
    String? busca,
    String? ordenarPor,
    bool? apenasAbertas,
    double? latitude,
    double? longitude,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 [LojaRepositoryImpl.getLojas] INICIANDO');
    debugPrint('🌐 [LojaRepositoryImpl.getLojas] Parâmetros:');
    debugPrint('   - page: $page');
    debugPrint('   - perPage: $perPage');
    debugPrint('   - latitude: $latitude');
    debugPrint('   - longitude: $longitude');
    debugPrint('🌐 [LojaRepositoryImpl.getLojas] Dio baseUrl: ${_apiClient.dio.options.baseUrl}');

    final queryParams = {
      'page': page,
      'per_page': perPage,
      if (categoria != null && categoria.isNotEmpty) 'categoria': categoria,
      if (busca != null && busca.isNotEmpty) 'search': busca,
      if (ordenarPor != null && ordenarPor.isNotEmpty) 'order_by': ordenarPor,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    debugPrint('🌐 [LojaRepositoryImpl.getLojas] Query params: $queryParams');

    try {
      debugPrint('🌐 [LojaRepositoryImpl.getLojas] Enviando GET /app/lojas...');
      final response = await _apiClient.get(
        '/app/lojas',
        queryParameters: queryParams,
        requiresAuth: false,
      );

      debugPrint('✅ [LojaRepositoryImpl.getLojas] Resposta recebida - Status: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        debugPrint('🔄 [LojaRepositoryImpl.getLojas] Iniciando parsing...');
        final result = LojaResumoResponseModel.fromJson(response.data);
        debugPrint('✅ [LojaRepositoryImpl.getLojas] Parsing concluído');
        debugPrint('   - Total de itens mapeados: ${result.items.length}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return result;
      } else {
        debugPrint('⚠️ [LojaRepositoryImpl.getLojas] API retornou sucesso false: ${response.data['message']}');
        throw Exception(response.data['message'] ?? 'Erro ao buscar lojas');
      }
    } on DioException catch (e) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [LojaRepositoryImpl.getLojas] DioException CAPTURADA');
      debugPrint('❌ URI: ${e.requestOptions.uri}');
      debugPrint('❌ Tipo: ${e.type}');
      debugPrint('❌ Mensagem: ${e.message}');
      debugPrint('❌ Response status: ${e.response?.statusCode}');
      debugPrint('❌ Response data: ${e.response?.data}');
      debugPrint('❌ StackTrace: ${e.stackTrace}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [LojaRepositoryImpl.getLojas] ERRO GENÉRICO');
      debugPrint('❌ Tipo: ${e.runtimeType}');
      debugPrint('❌ Mensagem: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  @override
  Future<LojaResumo> getLojaById(int id) async {
    final response = await _apiClient.get('/app/lojas/$id', requiresAuth: false);
    return LojaResumo.fromJson(response.data['data']);
  }

  @override
  Future<List<LojaResumo>> getLojasDestaque() async {
    final response = await _apiClient.get('/app/lojas/destaque', requiresAuth: false);
    if (response.data['success'] == true) {
      final List items = response.data['data'];
      return items.map((json) => LojaResumo.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<List<CategoriaTipo>> getCategorias() async {
    return [];
  }
}
