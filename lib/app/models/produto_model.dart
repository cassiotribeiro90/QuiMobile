
import 'package:equatable/equatable.dart';

class Produto extends Equatable {
  final int id;
  final int lojaId;
  final String nome;
  final String descricao;
  final double preco;
  final double? precoPromocional;
  final String categoria;
  final String? subcategoria;
  final String imagem;
  final List<String> ingredientes;
  final bool disponivel;
  final bool destaque;
  final bool maisVendido;
  final int? tempoPreparoMin; // em minutos
  final Map<String, dynamic>? opcoes; // para personalizações
  final double? avaliacao;
  final int? totalAvaliacoes;

  const Produto({
    required this.id,
    required this.lojaId,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.precoPromocional,
    required this.categoria,
    this.subcategoria,
    required this.imagem,
    required this.ingredientes,
    this.disponivel = true,
    this.destaque = false,
    this.maisVendido = false,
    this.tempoPreparoMin,
    this.opcoes,
    this.avaliacao,
    this.totalAvaliacoes,
  });

  // Getter para preço atual (considerando promoção)
  double get precoAtual => precoPromocional ?? preco;

  // Getter para verificar se está em promoção
  bool get emPromocao => precoPromocional != null && precoPromocional! < preco;

  // Getter para desconto percentual
  int? get descontoPercentual {
    if (!emPromocao) return null;
    return ((preco - precoPromocional!) / preco * 100).round();
  }

  // Formatação de preço
  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2)}';
  String get precoPromocionalFormatado => precoPromocional != null
      ? 'R\$ ${precoPromocional!.toStringAsFixed(2)}'
      : '';

  factory Produto.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw ArgumentError('JSON não pode ser nulo');

    return Produto(
      id: json['id'] as int? ?? 0,
      lojaId: json['lojaId'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      preco: (json['preco'] as num?)?.toDouble() ?? 0.0,
      precoPromocional: json['precoPromocional'] != null
          ? (json['precoPromocional'] as num?)?.toDouble()
          : null,
      categoria: json['categoria'] as String? ?? 'Outros',
      subcategoria: json['subcategoria'] as String?,
      imagem: json['imagem'] as String? ?? '',
      ingredientes: (json['ingredientes'] as List? ?? [])
          .map((i) => i as String)
          .toList(),
      disponivel: json['disponivel'] as bool? ?? true,
      destaque: json['destaque'] as bool? ?? false,
      maisVendido: json['maisVendido'] as bool? ?? false,
      tempoPreparoMin: json['tempoPreparoMin'] as int?,
      opcoes: json['opcoes'] as Map<String, dynamic>?,
      avaliacao: json['avaliacao'] != null
          ? (json['avaliacao'] as num?)?.toDouble()
          : null,
      totalAvaliacoes: json['totalAvaliacoes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lojaId': lojaId,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'precoPromocional': precoPromocional,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'imagem': imagem,
      'ingredientes': ingredientes,
      'disponivel': disponivel,
      'destaque': destaque,
      'maisVendido': maisVendido,
      'tempoPreparoMin': tempoPreparoMin,
      'opcoes': opcoes,
      'avaliacao': avaliacao,
      'totalAvaliacoes': totalAvaliacoes,
    };
  }

  Produto copyWith({
    int? id,
    int? lojaId,
    String? nome,
    String? descricao,
    double? preco,
    double? precoPromocional,
    String? categoria,
    String? subcategoria,
    String? imagem,
    List<String>? ingredientes,
    bool? disponivel,
    bool? destaque,
    bool? maisVendido,
    int? tempoPreparoMin,
    Map<String, dynamic>? opcoes,
    double? avaliacao,
    int? totalAvaliacoes,
  }) {
    return Produto(
      id: id ?? this.id,
      lojaId: lojaId ?? this.lojaId,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      precoPromocional: precoPromocional ?? this.precoPromocional,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      imagem: imagem ?? this.imagem,
      ingredientes: ingredientes ?? this.ingredientes,
      disponivel: disponivel ?? this.disponivel,
      destaque: destaque ?? this.destaque,
      maisVendido: maisVendido ?? this.maisVendido,
      tempoPreparoMin: tempoPreparoMin ?? this.tempoPreparoMin,
      opcoes: opcoes ?? this.opcoes,
      avaliacao: avaliacao ?? this.avaliacao,
      totalAvaliacoes: totalAvaliacoes ?? this.totalAvaliacoes,
    );
  }

  @override
  List<Object?> get props => [
    id, lojaId, nome, preco, precoPromocional,
    disponivel, destaque, maisVendido
  ];
}