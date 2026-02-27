import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'enums.dart';

// Classe para o objeto aninhado de endereço, espelhando o JSON.
class Endereco {
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

  factory Endereco.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON do endereço não pode ser nulo');
    }
    return Endereco(
      rua: json['rua'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: json['cidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'rua': rua,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
        'lat': lat,
        'lng': lng,
      };

  @override
  String toString() {
    return '$rua, $bairro - $cidade/$uf';
  }
}

class Loja {
  final int id;
  final String nome;
  final String descricao;
  final CategoriaTipo categoria;
  final String logo;
  final String capa;
  final double nota;
  final Endereco endereco;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final double taxaEntrega;
  final double pedidoMinimo;
  final List<TipoPagamento> formasPagamento;
  final Map<String, String> horarioFuncionamento;
  final bool favoritado;
  final bool destaque;
  double? distanciaKm;

  Loja({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.logo,
    required this.capa,
    required this.nota,
    required this.endereco,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.taxaEntrega,
    required this.pedidoMinimo,
    required this.formasPagamento,
    required this.horarioFuncionamento,
    this.favoritado = false,
    this.destaque = false,
    this.distanciaKm,
  });

  // Status da loja baseado no horário de funcionamento
  StatusLoja get status {
    final now = DateTime.now();
    // Lógica robusta usando o weekday do DateTime (1 para segunda, 7 para domingo)
    const dayMap = {
      1: 'segunda',
      2: 'terca',
      3: 'quarta',
      4: 'quinta',
      5: 'sexta',
      6: 'sabado',
      7: 'domingo',
    };
    final dayKey = dayMap[now.weekday];
    final horarioHoje = horarioFuncionamento[dayKey];

    if (horarioHoje == null || horarioHoje.toLowerCase() == 'fechado') {
      return StatusLoja.fechado;
    }

    try {
      final parts = horarioHoje.split('-');
      if (parts.length != 2) return StatusLoja.fechado;

      final aberturaParts = parts[0].trim().split(':');
      final fechamentoParts = parts[1].trim().split(':');

      if (aberturaParts.length != 2 || fechamentoParts.length != 2) {
        return StatusLoja.fechado;
      }

      final aberturaTime = DateTime(now.year, now.month, now.day, int.parse(aberturaParts[0]), int.parse(aberturaParts[1]));
      var fechamentoTime = DateTime(now.year, now.month, now.day, int.parse(fechamentoParts[0]), int.parse(fechamentoParts[1]));

      // Lida com horário que passa da meia-noite (ex: 18:00-02:00)
      if (fechamentoTime.isBefore(aberturaTime)) {
        if (now.isBefore(aberturaTime)) {
          // Ex: agora são 1h da manhã, a loja abre às 18h e fecha às 2h. A abertura foi ontem.
          final aberturaOntem = aberturaTime.subtract(const Duration(days: 1));
          return now.isAfter(aberturaOntem) && now.isBefore(fechamentoTime)
              ? StatusLoja.aberto
              : StatusLoja.fechado;
        } else {
          // Ex: agora são 20h, a loja abre às 18h e fecha às 2h. O fechamento é amanhã.
          fechamentoTime = fechamentoTime.add(const Duration(days: 1));
        }
      }

      return now.isAfter(aberturaTime) && now.isBefore(fechamentoTime)
          ? StatusLoja.aberto
          : StatusLoja.fechado;
    } catch (e) {
      debugPrint('Erro ao processar horário para loja $id: $e');
      return StatusLoja.fechado;
    }
  }

  // Formatações
  String get tempoEntregaFormatado => '$tempoEntregaMin-$tempoEntregaMax min';
  String get taxaEntregaFormatada => taxaEntrega == 0 ? 'Frete grátis' : NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(taxaEntrega);
  String get enderecoCompleto => endereco.toString();
  bool get isOpenNow => status == StatusLoja.aberto;

  // Factory methods
  static CategoriaTipo _parseCategoria(String categoria) {
    return CategoriaTipo.values.firstWhere(
          (e) => e.name.toLowerCase() == categoria.toLowerCase(),
          orElse: () => CategoriaTipo.outros,
    );
  }

  static TipoPagamento _parsePagamento(String pagamento) {
    return TipoPagamento.values.firstWhere(
          (e) => e.name.toLowerCase() == pagamento.toLowerCase(),
          orElse: () => TipoPagamento.credito,
    );
  }

  factory Loja.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON da loja não pode ser nulo');
    }

    return Loja(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      categoria: _parseCategoria(json['categoria'] as String? ?? ''),
      logo: json['logo'] as String? ?? '',
      capa: json['capa'] as String? ?? '',
      nota: (json['nota'] as num?)?.toDouble() ?? 0.0,
      endereco: Endereco.fromJson(json['endereco'] as Map<String, dynamic>?),
      tempoEntregaMin: json['tempoEntregaMin'] as int? ?? 30,
      tempoEntregaMax: json['tempoEntregaMax'] as int? ?? 50,
      taxaEntrega: (json['taxaEntrega'] as num?)?.toDouble() ?? 0.0,
      pedidoMinimo: (json['pedidoMinimo'] as num?)?.toDouble() ?? 0.0,
      formasPagamento: (json['formasPagamento'] as List? ?? []).map((p) => _parsePagamento(p as String? ?? '')).toList(),
      horarioFuncionamento: Map<String, String>.from(json['horarioFuncionamento'] as Map? ?? {}),
      favoritado: json['favoritado'] as bool? ?? false,
      destaque: json['destaque'] as bool? ?? false,
      distanciaKm: (json['distanciaKm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria.name,
      'logo': logo,
      'capa': capa,
      'nota': nota,
      'endereco': endereco.toJson(),
      'tempoEntregaMin': tempoEntregaMin,
      'tempoEntregaMax': tempoEntregaMax,
      'taxaEntrega': taxaEntrega,
      'pedidoMinimo': pedidoMinimo,
      'formasPagamento': formasPagamento.map((p) => p.name).toList(),
      'horarioFuncionamento': horarioFuncionamento,
      'favoritado': favoritado,
      'destaque': destaque,
      'distanciaKm': distanciaKm,
    };
  }
}
