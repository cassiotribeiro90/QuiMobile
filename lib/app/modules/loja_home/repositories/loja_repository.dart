import 'dart:convert';
import 'package:flutter/services.dart';
import '../../lojas/models/loja.dart';

abstract class ILojaRepository {
  Future<Loja> getLojaById(int id);
}

class LojaRepositoryMock implements ILojaRepository {
  @override
  Future<Loja> getLojaById(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final String jsonString = await rootBundle.loadString('lib/app/assets/data/lojas.json');
      final data = json.decode(jsonString);
      final List<dynamic> lojasData = data['lojas'];

      final lojaData = lojasData.firstWhere((loja) => loja['id'] == id, orElse: () => null);

      if (lojaData != null) {
        return Loja.fromJson(lojaData);
      } else {
        throw Exception('Loja não encontrada');
      }
    } catch (e) {
      // Fallback para quando o JSON não existe ou o ID não é encontrado no mock
      return Loja(
        id: id,
        nome: 'Loja $id',
        categoria: 'Alimentação',
        cidade: 'Cidade',
        uf: 'UF',
        notaMedia: 4.5,
        tempoEntregaMin: 30,
        tempoEntregaMax: 45,
        taxaEntrega: 5.0,
        pedidoMinimo: 20.0,
      );
    }
  }
}
