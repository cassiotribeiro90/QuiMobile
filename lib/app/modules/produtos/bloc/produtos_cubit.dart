import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/api/api_client.dart';
import '../../../models/produto_model.dart';
import 'produtos_state.dart';

class ProdutosCubit extends Cubit<ProdutosState> {
  final ApiClient _apiClient;

  ProdutosCubit(this._apiClient) : super(ProdutosInitial());

  Future<void> fetchProdutoDetail(int id) async {
    emit(ProdutosLoading());
    try {
      final response = await _apiClient.get('/produtos/$id');
      
      if (response.data['success'] == true) {
        final produto = Produto.fromJson(response.data['data']);
        emit(ProdutoDetailLoaded(produto));
      } else {
        emit(ProdutosError(response.data['message'] ?? 'Erro ao carregar produto'));
      }
    } catch (e) {
      emit(const ProdutosError('Erro de conexão ao carregar detalhes do produto'));
    }
  }
}
