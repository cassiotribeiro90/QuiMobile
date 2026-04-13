import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localizacao_state.dart';

class LocalizacaoCubit extends Cubit<LocalizacaoState> {
  final SharedPreferences _prefs;

  LocalizacaoCubit(this._prefs) : super(LocalizacaoInitial());

  /// Atualiza a posição atual (vinda do GPS)
  void atualizarPosicao(Position posicao) {
    emit(LocalizacaoCarregada(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
      origem: 'gps',
    ));
  }

  /// Carrega localização a partir do endereço padrão salvo
  Future<void> carregarLocalizacaoDoEnderecoPadrao() async {
    final enderecoPadrao = _prefs.getString('endereco_padrao');
    
    if (enderecoPadrao != null) {
      try {
        final Map<String, dynamic> endereco = jsonDecode(enderecoPadrao);
        final lat = endereco['latitude'];
        final lon = endereco['longitude'];
        if (lat != null && lon != null) {
          emit(LocalizacaoCarregada(
            latitude: (lat as num).toDouble(),
            longitude: (lon as num).toDouble(),
            origem: 'endereco_padrao',
          ));
        } else {
          emit(LocalizacaoNaoEncontrada());
        }
      } catch (e) {
        emit(LocalizacaoNaoEncontrada());
      }
    } else {
      emit(LocalizacaoNaoEncontrada());
    }
  }

  /// Define um endereço manual como localização atual
  void definirLocalizacaoManual(double lat, double lon) {
    emit(LocalizacaoCarregada(
      latitude: lat,
      longitude: lon,
      origem: 'manual',
    ));
  }
}
