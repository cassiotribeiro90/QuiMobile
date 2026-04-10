class VerificacaoLojaResponse {
  final bool mesmaLoja;
  final bool carrinhoVazio;
  final int? lojaIdAtual;
  final String? lojaNomeAtual;

  VerificacaoLojaResponse({
    required this.mesmaLoja,
    required this.carrinhoVazio,
    this.lojaIdAtual,
    this.lojaNomeAtual,
  });

  factory VerificacaoLojaResponse.fromJson(Map<String, dynamic> json) {
    return VerificacaoLojaResponse(
      mesmaLoja: json['mesma_loja'] ?? true,
      carrinhoVazio: json['carrinho_vazio'] ?? true,
      lojaIdAtual: json['loja_id_atual'],
      lojaNomeAtual: json['loja_nome_atual'],
    );
  }
}
