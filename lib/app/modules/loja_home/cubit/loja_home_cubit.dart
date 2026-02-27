import 'package:bloc/bloc.dart';
import 'package:qui/app/modules/loja_avaliacoes/cubit/loja_avaliacoes_cubit.dart';
import '../repositories/loja_repository.dart';
import 'loja_home_state.dart';

class LojaHomeCubit extends Cubit<LojaHomeState> {
  final ILojaRepository _lojaRepository;
  late final LojaAvaliacoesCubit avaliacoesCubit;

  LojaHomeCubit(this._lojaRepository) : super(LojaHomeInitial());

  Future<void> fetchLojaDetails(int lojaId) async {
    try {
      emit(LojaHomeLoading());
      final loja = await _lojaRepository.getLojaById(lojaId);
      avaliacoesCubit = LojaAvaliacoesCubit(lojaId)..loadAvaliacoes();
      emit(LojaHomeLoaded(loja));
    } catch (e) {
      emit(LojaHomeError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    avaliacoesCubit.close();
    return super.close();
  }
}
