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

  Endereco copyWith({
    String? rua,
    String? bairro,
    String? cidade,
    String? uf,
    double? lat,
    double? lng,
  }) {
    return Endereco(
      rua: rua ?? this.rua,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

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
    final weekDay = DateFormat('EEEE', 'pt_BR').format(now).toLowerCase();

    // Mapeamento para português
    final dayMap = {
      'segunda': 'monday',
      'terça': 'tuesday',
      'quarta': 'wednesday',
      'quinta': 'thursday',
      'sexta': 'friday',
      'sábado': 'saturday',
      'domingo': 'sunday',
    };

    final dayKey = dayMap[weekDay] ?? weekDay;
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

      final aberturaTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(aberturaParts[0]),
          int.parse(aberturaParts[1])
      );

      var fechamentoTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(fechamentoParts[0]),
          int.parse(fechamentoParts[1])
      );

      // Lida com horário que passa da meia-noite
      if (fechamentoTime.isBefore(aberturaTime)) {
        fechamentoTime = fechamentoTime.add(const Duration(days: 1));
      }

      return now.isAfter(aberturaTime) && now.isBefore(fechamentoTime)
          ? StatusLoja.aberto
          : StatusLoja.fechado;
    } catch (e) {
      debugPrint('Erro ao processar horário: $e');
      return StatusLoja.fechado;
    }
  }

  // Formatações
  String get tempoEntregaFormatado {
    if (tempoEntregaMin == tempoEntregaMax) {
      return '$tempoEntregaMin min';
    }
    return '$tempoEntregaMin-$tempoEntregaMax min';
  }

  String get taxaEntregaFormatada {
    if (taxaEntrega == 0) return 'Frete grátis';
    if (taxaEntrega < 0) return 'Frete a combinar';
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(taxaEntrega);
  }

  String get pedidoMinimoFormatado {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(pedidoMinimo);
  }

  String get enderecoCompleto => endereco.toString();

  String? get distanciaFormatada {
    if (distanciaKm == null) return null;
    if (distanciaKm! < 1) {
      return '${(distanciaKm! * 1000).toInt()}m';
    }
    return '${distanciaKm!.toStringAsFixed(1)}km';
  }

  bool get isOpenNow => status == StatusLoja.aberto;

  // Factory methods
  static CategoriaTipo _parseCategoria(String categoria) {
    try {
      return CategoriaTipo.values.firstWhere(
            (e) => e.name.toLowerCase() == categoria.toLowerCase(),
      );
    } catch (e) {
      debugPrint('Categoria não reconhecida: $categoria, usando "outros"');
      return CategoriaTipo.outros;
    }
  }

  static TipoPagamento _parsePagamento(String pagamento) {
    try {
      return TipoPagamento.values.firstWhere(
            (e) => e.name.toLowerCase() == pagamento.toLowerCase(),
      );
    } catch (e) {
      debugPrint('Pagamento não reconhecido: $pagamento, usando "credito"');
      return TipoPagamento.credito;
    }
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
      formasPagamento: (json['formasPagamento'] as List? ?? [])
          .map((p) => _parsePagamento(p as String? ?? ''))
          .toList(),
      horarioFuncionamento: Map<String, String>.from(
          json['horarioFuncionamento'] as Map? ?? {}
      ),
      favoritado: json['favoritado'] as bool? ?? false,
      destaque: json['destaque'] as bool? ?? false,
      distanciaKm: json['distanciaKm'] != null
          ? (json['distanciaKm'] as num?)?.toDouble()
          : null,
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

  // CopyWith para facilitar atualizações
  Loja copyWith({
    int? id,
    String? nome,
    String? descricao,
    CategoriaTipo? categoria,
    String? logo,
    String? capa,
    double? nota,
    Endereco? endereco,
    int? tempoEntregaMin,
    int? tempoEntregaMax,
    double? taxaEntrega,
    double? pedidoMinimo,
    List<TipoPagamento>? formasPagamento,
    Map<String, String>? horarioFuncionamento,
    bool? favoritado,
    bool? destaque,
    double? distanciaKm,
  }) {
    return Loja(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      logo: logo ?? this.logo,
      capa: capa ?? this.capa,
      nota: nota ?? this.nota,
      endereco: endereco ?? this.endereco,
      tempoEntregaMin: tempoEntregaMin ?? this.tempoEntregaMin,
      tempoEntregaMax: tempoEntregaMax ?? this.tempoEntregaMax,
      taxaEntrega: taxaEntrega ?? this.taxaEntrega,
      pedidoMinimo: pedidoMinimo ?? this.pedidoMinimo,
      formasPagamento: formasPagamento ?? this.formasPagamento,
      horarioFuncionamento: horarioFuncionamento ?? this.horarioFuncionamento,
      favoritado: favoritado ?? this.favoritado,
      destaque: destaque ?? this.destaque,
      distanciaKm: distanciaKm ?? this.distanciaKm,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Loja &&
        other.id == id &&
        other.nome == nome &&
        other.favoritado == favoritado;
  }

  @override
  int get hashCode => id.hashCode;
}

// Extension com funcionalidades extras
extension LojaListExtension on List<Loja> {
  List<Loja> get favoritas => where((l) => l.favoritado).toList();

  List<Loja> get abertas => where((l) => l.isOpenNow).toList();

  List<Loja> ordernarPorDistancia() {
    return [...this]..sort((a, b) {
      if (a.distanciaKm == null) return 1;
      if (b.distanciaKm == null) return -1;
      return a.distanciaKm!.compareTo(b.distanciaKm!);
    });
  }

  List<Loja> ordernarPorNota() {
    return [...this]..sort((a, b) => b.nota.compareTo(a.nota));
  }

  List<Loja> filtrarPorCategoria(CategoriaTipo categoria) {
    return where((l) => l.categoria == categoria).toList();
  }
}