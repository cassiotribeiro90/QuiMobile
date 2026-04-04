import '../../../../shared/api/api_client.dart';
import '../models/loja.dart';
import '../models/loja_response_model.dart';
import '../models/enums.dart';
import 'loja_repository.dart';

class LojaRepositoryImpl implements LojaRepository {
  final ApiClient _apiClient;

  LojaRepositoryImpl(this._apiClient);

  @override
  Future<LojaResponseModel> getLojas({
    int page = 1,
    int perPage = 10,
    String? categoria,
    String? busca,
    String? ordenarPor,
    bool? apenasAbertas,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.get(
      '/app/loja',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (categoria != null) 'categoria': categoria,
        if (busca != null) 'search': busca,
        if (ordenarPor != null) 'order_by': ordenarPor,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );

    if (response.data['success'] == true) {
      return LojaResponseModel.fromJson(response.data);
    } else {
      throw Exception(response.data['message'] ?? 'Erro ao buscar lojas');
    }
  }

  @override
  Future<Loja> getLojaById(int id) async {
    final response = await _apiClient.get('/app/loja/$id');
    return Loja.fromJson(response.data['data']);
  }

  @override
  Future<List<Loja>> getLojasDestaque() async {
    final response = await _apiClient.get('/app/loja/destaque');
    if (response.data['success'] == true) {
      final List items = response.data['data'];
      return items.map((json) => Loja.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<List<CategoriaTipo>> getCategorias() async {
    return [];
  }
}
