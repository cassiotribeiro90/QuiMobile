import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class EnderecoModel extends Equatable {
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String? referencia;
  final String bairro;
  final String cidade;
  final String uf;
  final double? latitude;
  final double? longitude;

  const EnderecoModel({
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    this.referencia,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.latitude,
    this.longitude,
  });

  String get resumido {
    if (logradouro.isEmpty) return 'Endereço definido';
    final buffer = StringBuffer(logradouro);
    if (numero.isNotEmpty && numero != 'S/N') {
      buffer.write(', $numero');
    }
    return buffer.toString();
  }

  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔄 [EnderecoModel.fromJson] Iniciando parsing');
      debugPrint('   - Keys recebidas: ${json.keys.join(', ')}');
      
      final camposObrigatorios = ['logradouro', 'numero', 'bairro', 'cidade', 'uf'];
      for (var campo in camposObrigatorios) {
        if (!json.containsKey(campo)) {
          debugPrint('⚠️ [EnderecoModel.fromJson] Campo "$campo" NÃO ENCONTRADO!');
        } else if (json[campo] == null) {
          debugPrint('⚠️ [EnderecoModel.fromJson] Campo "$campo" é NULL!');
        } else {
          debugPrint('   - $campo: ${json[campo]} (${json[campo].runtimeType})');
        }
      }
      
      debugPrint('   - latitude: ${json['latitude']} (${json['latitude'].runtimeType})');
      debugPrint('   - longitude: ${json['longitude']} (${json['longitude'].runtimeType})');

      final result = EnderecoModel(
        cep: json['cep']?.toString() ?? '',
        logradouro: json['logradouro']?.toString() ?? '',
        numero: json['numero']?.toString() ?? 'S/N',
        complemento: json['complemento']?.toString(),
        referencia: json['referencia']?.toString(),
        bairro: json['bairro']?.toString() ?? '',
        cidade: json['cidade']?.toString() ?? '',
        uf: json['uf']?.toString() ?? '',
        latitude: _parseDouble(json['latitude']),
        longitude: _parseDouble(json['longitude']),
      );

      debugPrint('✅ [EnderecoModel.fromJson] Parsing concluído: ${result.resumido}');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ [EnderecoModel.fromJson] ERRO NO PARSING');
      debugPrint('❌ Tipo: ${e.runtimeType}');
      debugPrint('❌ Mensagem: $e');
      debugPrint('❌ JSON recebido: $json');
      debugPrint('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'cep': cep,
    'logradouro': logradouro,
    'numero': numero,
    'complemento': complemento,
    'referencia': referencia,
    'bairro': bairro,
    'cidade': cidade,
    'uf': uf,
    'latitude': latitude,
    'longitude': longitude,
  };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        debugPrint('⚠️ [EnderecoModel._parseDouble] Falha ao parsear String para double: "$value"');
      }
      return parsed;
    }
    debugPrint('⚠️ [EnderecoModel._parseDouble] Tipo inesperado: ${value.runtimeType} (valor: $value)');
    return null;
  }

  @override
  List<Object?> get props => [
    cep, logradouro, numero, complemento, referencia, 
    bairro, cidade, uf, latitude, longitude
  ];

  EnderecoModel copyWith({
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? referencia,
    String? bairro,
    String? cidade,
    String? uf,
    double? latitude,
    double? longitude,
  }) {
    return EnderecoModel(
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      referencia: referencia ?? this.referencia,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
