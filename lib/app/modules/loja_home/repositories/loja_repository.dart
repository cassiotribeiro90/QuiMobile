import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../models/loja_model.dart';

abstract class ILojaRepository {
  Future<Loja> getLojaById(int id);
}

class LojaRepositoryMock implements ILojaRepository {
  @override
  Future<Loja> getLojaById(int id) async {
    // Simula um delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    final String jsonString = await rootBundle.loadString('lib/app/assets/data/lojas.json');
    final data = json.decode(jsonString);
    final List<dynamic> lojasData = data['lojas'];

    final lojaData = lojasData.firstWhere((loja) => loja['id'] == id, orElse: () => null);

    if (lojaData != null) {
      return Loja.fromJson(lojaData);
    } else {
      throw Exception('Loja não encontrada');
    }
  }
}
