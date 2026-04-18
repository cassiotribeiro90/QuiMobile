import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/endereco_model.dart';
import 'localizacao_state.dart';

class LocalizacaoCubit extends Cubit<LocalizacaoState> {
  final SharedPreferences _prefs;

  LocalizacaoCubit(this._prefs) : super(LocalizacaoInitial());

  /// Atualiza a posição atual (vinda do GPS)
  void atualizarPosicao(Position posicao, {String? enderecoFormatado}) {
    final endereco = EnderecoModel(
      cep: '',
      logradouro: enderecoFormatado ?? 'Localização atual',
      numero: 'S/N',
      bairro: '',
      cidade: '',
      uf: '',
      latitude: posicao.latitude,
      longitude: posicao.longitude,
    );

    final estado = LocalizacaoCarregada(
      endereco: endereco,
      origem: 'gps',
    );
    _salvarLocalizacao(estado);
    emit(estado);
  }

  /// Carrega localização a partir do endereço padrão salvo
  Future<void> carregarLocalizacaoDoEnderecoPadrao() async {
    final enderecoJson = _prefs.getString('endereco_padrao');
    
    if (enderecoJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(enderecoJson);
        final endereco = EnderecoModel.fromJson(data);
        emit(LocalizacaoCarregada(
          endereco: endereco,
          origem: data['origem'] ?? 'endereco_padrao',
        ));
      } catch (e) {
        emit(LocalizacaoNaoEncontrada());
      }
    } else {
      emit(LocalizacaoNaoEncontrada());
    }
  }

  /// Define um endereço manual como localização atual
  void definirLocalizacaoManual({
    required double latitude,
    required double longitude,
    String? enderecoFormatado,
    String? referencia,
  }) {
    // Para manter compatibilidade com as chamadas existentes, criamos o modelo aqui
    final endereco = EnderecoModel(
      cep: '',
      logradouro: enderecoFormatado ?? 'Endereço definido',
      numero: '',
      bairro: '',
      cidade: '',
      uf: '',
      referencia: referencia,
      latitude: latitude,
      longitude: longitude,
    );

    final estado = LocalizacaoCarregada(
      endereco: endereco,
      origem: 'manual',
    );
    _salvarLocalizacao(estado);
    emit(estado);
  }

  /// Define a localização a partir de um modelo completo (após confirmação da API)
  void definirEnderecoCompleto(EnderecoModel endereco, {String origem = 'manual'}) {
    final estado = LocalizacaoCarregada(
      endereco: endereco,
      origem: origem,
    );
    _salvarLocalizacao(estado);
    emit(estado);
  }

  Future<void> _salvarLocalizacao(LocalizacaoCarregada estado) async {
    final data = estado.endereco.toJson();
    data['origem'] = estado.origem;
    await _prefs.setString('endereco_padrao', jsonEncode(data));
  }

  Future<void> limparLocalizacao() async {
    await _prefs.remove('endereco_padrao');
    emit(LocalizacaoNaoEncontrada());
  }
}
