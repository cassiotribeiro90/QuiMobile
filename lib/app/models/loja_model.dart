import 'package:equatable/equatable.dart';

class Loja extends Equatable {
  final int id;
  final String nome;
  final String descricao;
  final String categoria;
  final String logo;
  final String capa;
  final double nota;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final double taxaEntrega;
  final double pedidoMinimo;
  final Endereco endereco;
  final HorarioFuncionamento horarioFuncionamento;
  final List<String> formasPagamento;
  final bool ativo;
  final bool destaque;

  const Loja({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.logo,
    required this.capa,
    required this.nota,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.taxaEntrega,
    required this.pedidoMinimo,
    required this.endereco,
    required this.horarioFuncionamento,
    required this.formasPagamento,
    required this.ativo,
    required this.destaque,
  });

  factory Loja.fromJson(Map<String, dynamic> json) {
    return Loja(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      categoria: json['categoria'],
      logo: json['logo'],
      capa: json['capa'],
      nota: (json['nota'] as num).toDouble(),
      tempoEntregaMin: json['tempoEntregaMin'],
      tempoEntregaMax: json['tempoEntregaMax'],
      taxaEntrega: (json['taxaEntrega'] as num).toDouble(),
      pedidoMinimo: (json['pedidoMinimo'] as num).toDouble(),
      endereco: Endereco.fromJson(json['endereco']),
      horarioFuncionamento: HorarioFuncionamento.fromJson(json['horarioFuncionamento']),
      formasPagamento: List<String>.from(json['formasPagamento']),
      ativo: json['ativo'],
      destaque: json['destaque'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        descricao,
        categoria,
        logo,
        capa,
        nota,
        tempoEntregaMin,
        tempoEntregaMax,
        taxaEntrega,
        pedidoMinimo,
        endereco,
        horarioFuncionamento,
        formasPagamento,
        ativo,
        destaque,
      ];
}

class Endereco extends Equatable {
  final String rua;
  final String bairro;
  final String cidade;
  final String uf;
  final double lat;
  final double lng;

  const Endereco({
    required this.rua,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.lat,
    required this.lng,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      rua: json['rua'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      uf: json['uf'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [rua, bairro, cidade, uf, lat, lng];
}

class HorarioFuncionamento extends Equatable {
  final String segunda;
  final String terca;
  final String quarta;
  final String quinta;
  final String sexta;
  final String sabado;
  final String domingo;

  const HorarioFuncionamento({
    required this.segunda,
    required this.terca,
    required this.quarta,
    required this.quinta,
    required this.sexta,
    required this.sabado,
    required this.domingo,
  });

  factory HorarioFuncionamento.fromJson(Map<String, dynamic> json) {
    return HorarioFuncionamento(
      segunda: json['segunda'],
      terca: json['terca'],
      quarta: json['quarta'],
      quinta: json['quinta'],
      sexta: json['sexta'],
      sabado: json['sabado'],
      domingo: json['domingo'],
    );
  }

  @override
  List<Object?> get props => [segunda, terca, quarta, quinta, sexta, sabado, domingo];
}
