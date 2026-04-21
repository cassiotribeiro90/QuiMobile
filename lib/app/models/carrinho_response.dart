import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'carrinho_item.dart';

class CarrinhoResponse extends Equatable {
  final String? mensagem;
  final List<CarrinhoItem> itens;
  final CarrinhoResumo resumo;

  const CarrinhoResponse({
    this.mensagem,
    required this.itens,
    required this.resumo,
  });

  factory CarrinhoResponse.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) print('🔍 Parsing CarrinhoResponse: \$json');
    
    return CarrinhoResponse(
      mensagem: json['mensagem']?.toString(),
      itens: (json['itens'] as List? ?? [])
          .map((e) => CarrinhoItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      resumo: json['resumo'] != null 
          ? CarrinhoResumo.fromJson(Map<String, dynamic>.from(json['resumo']))
          : const CarrinhoResumo(totalItens: 0, subtotal: 0, formasPagamento: {}),
    );
  }

  @override
  List<Object?> get props => [mensagem, itens, resumo];
}

class CarrinhoResumo extends Equatable {
  final int totalItens;
  final double subtotal;
  final int? lojaId;
  final String? lojaNome;
  final double? taxaEntrega;
  final double? total;
  final double? distanciaKm;
  final Map<String, dynamic> formasPagamento;

  const CarrinhoResumo({
    required this.totalItens,
    required this.subtotal,
    this.lojaId,
    this.lojaNome,
    this.taxaEntrega,
    this.total,
    this.distanciaKm,
    this.formasPagamento = const {},
  });

  factory CarrinhoResumo.fromJson(Map<String, dynamic> json) {
    return CarrinhoResumo(
      totalItens: int.tryParse(json['total_itens']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      lojaId: int.tryParse(json['loja_id']?.toString() ?? ''),
      lojaNome: json['loja_nome']?.toString(),
      taxaEntrega: double.tryParse(json['taxa_entrega']?.toString() ?? ''),
      total: double.tryParse(json['total']?.toString() ?? ''),
      distanciaKm: double.tryParse(json['distancia_km']?.toString() ?? ''),
      formasPagamento: Map<String, dynamic>.from(json['formas_pagamento'] ?? {}),
    );
  }

  /// Retorna as chaves das formas de pagamento disponíveis
  List<String> get formasDisponiveis => formasPagamento.keys.toList();
  
  /// Retorna o label de uma forma de pagamento
  String getLabel(String forma) {
    return formasPagamento[forma]?['label'] ?? forma;
  }

  @override
  List<Object?> get props => [
    totalItens, subtotal, lojaId, lojaNome, 
    taxaEntrega, total, distanciaKm, formasPagamento
  ];
}
