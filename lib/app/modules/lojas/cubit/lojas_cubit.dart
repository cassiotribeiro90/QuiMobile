import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'lojas_state.dart';
import '../../../models/loja_model.dart';

class LojasCubit extends Cubit<LojasState> {
  LojasCubit() : super(LojasInitial());

  Future<void> loadLojas() async {
    const String assetPath = 'lib/app/assets/data/lojas.json';

    try {
      emit(LojasLoading());

      // Limpa o cache para garantir uma nova leitura.
      ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/assets',
        const StandardMethodCodec().encodeMethodCall(MethodCall('evict', assetPath)),
        (ByteData? data) {},
      );

      final String jsonString = await rootBundle.loadString(assetPath);
      
      // Decodifica a string JSON para um mapa.
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Acessa a lista de lojas dentro da chave 'lojas'.
      final List<dynamic> lojasData = jsonData['lojas'] as List<dynamic>;

      // Converte a lista de JSON para uma lista de objetos Loja.
      final List<Loja> lojas = lojasData.map((data) => Loja.fromJson(data)).toList();

      emit(LojasLoaded(lojas));
    } catch (e) {
      emit(LojasError('Falha ao decodificar os dados: ${e.toString()}'));
    }
  }
}
