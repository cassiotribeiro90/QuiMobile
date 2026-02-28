import 'package:bloc/bloc.dart';
import '../../../models/loja_model.dart';
import '../../../models/produto_model.dart';
import '../repositories/loja_repository.dart';
import '../repositories/produto_repository.dart';
import 'loja_home_state.dart';

class LojaHomeCubit extends Cubit<LojaHomeState> {
  final ILojaRepository _lojaRepository;
  final IProdutoRepository _produtoRepository;
  final int lojaId;

  LojaHomeCubit(this._lojaRepository, this._produtoRepository, this.lojaId)
      : super(LojaHomeInitial());

  Future<void> fetchLojaDetails() async {
    try {
      emit(LojaHomeLoading());

      // Carrega detalhes da loja e produtos em paralelo
      final results = await Future.wait([
        _lojaRepository.getLojaById(lojaId),
        _produtoRepository.getProdutosByLojaId(lojaId),
      ]);

      final loja = results[0] as Loja;
      final produtos = results[1] as List<Produto>;

      // Agrupa os produtos por categoria
      final produtosPorCategoria = <String, List<Produto>>{};
      for (var produto in produtos) {
        (produtosPorCategoria[produto.categoria] ??= []).add(produto);
      }

      emit(LojaHomeLoaded(loja, produtos, produtosPorCategoria));
    } catch (e) {
      emit(LojaHomeError(e.toString()));
    }
  }
}
