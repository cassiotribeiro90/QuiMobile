import 'package:quipede/app/models/carrinho_response.dart';

class CarrinhoResult {
  final bool success;
  final int? code;
  final String? message;
  final CarrinhoResponse? data;      // quando sucesso (200)
  final CarrinhoConflito? conflito;  // quando conflito (409)

  CarrinhoResult.success(this.data)
      : success = true,
        code = 200,
        message = null,
        conflito = null;

  CarrinhoResult.conflito(this.conflito)
      : success = false,
        code = 409,
        message = conflito?.message,
        data = null;

  CarrinhoResult.error(this.message, {this.code = 500})
      : success = false,
        data = null,
        conflito = null;

  bool get isConflito => code == 409;
}

class CarrinhoConflito {
  final String acao;
  final int lojaAtual;
  final int novaLoja;
  final String? lojaAtualNome;
  final String message;

  CarrinhoConflito({
    required this.acao,
    required this.lojaAtual,
    required this.novaLoja,
    this.lojaAtualNome,
    required this.message,
  });

  factory CarrinhoConflito.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? json['data'] ?? {};
    return CarrinhoConflito(
      acao: status['acao'] ?? 'limpar_carrinho',
      lojaAtual: status['loja_atual'] ?? 0,
      novaLoja: status['nova_loja'] ?? 0,
      lojaAtualNome: status['loja_atual_nome'],
      message: json['message'] ?? 'Conflito de loja detectado',
    );
  }
}
