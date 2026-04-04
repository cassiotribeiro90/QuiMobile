import 'package:equatable/equatable.dart';
import 'produto_model.dart';

class SecaoModel extends Equatable {
  final int id;
  final String nome;
  final String? icone;
  final int ordem;
  final int totalProdutos;
  final List<ProdutoModel> produtos;

  const SecaoModel({
    required this.id,
    required this.nome,
    this.icone,
    required this.ordem,
    required this.totalProdutos,
    required this.produtos,
  });

  factory SecaoModel.fromJson(Map<String, dynamic> json) {
    return SecaoModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      icone: json['icone'] as String?,
      ordem: json['ordem'] as int? ?? 0,
      totalProdutos: (json['total_produtos'] ?? json['totalProdutos'] ?? 0) as int,
      produtos: (json['produtos'] as List? ?? [])
          .map((e) => ProdutoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, nome, icone, ordem, totalProdutos, produtos];
}
