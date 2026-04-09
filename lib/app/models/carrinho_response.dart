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
          : const CarrinhoResumo(totalItens: 0, subtotal: 0),
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

  const CarrinhoResumo({
    required this.totalItens,
    required this.subtotal,
    this.lojaId,
    this.lojaNome,
  });

  factory CarrinhoResumo.fromJson(Map<String, dynamic> json) {
    return CarrinhoResumo(
      totalItens: int.tryParse(json['total_itens']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      lojaId: int.tryParse(json['loja_id']?.toString() ?? ''),
      lojaNome: json['loja_nome']?.toString(),
    );
  }

  @override
  List<Object?> get props => [totalItens, subtotal, lojaId, lojaNome];
}
