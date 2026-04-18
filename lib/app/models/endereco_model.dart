class EnderecoModel {
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

  EnderecoModel({
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
    if (bairro.isNotEmpty) {
      buffer.write(' - $bairro');
    }
    return buffer.toString();
  }

  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
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
    if (value is String) return double.tryParse(value);
    return null;
  }
}
