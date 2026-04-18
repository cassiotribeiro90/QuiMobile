import 'package:equatable/equatable.dart';

abstract class LocalizacaoState extends Equatable {
  const LocalizacaoState();
  @override
  List<Object?> get props => [];
}

class LocalizacaoInitial extends LocalizacaoState {}

class LocalizacaoCarregada extends LocalizacaoState {
  final double latitude;
  final double longitude;
  final String? enderecoFormatado;
  final String? referencia; // ← novo campo
  final String origem; // 'gps', 'endereco_padrao', 'manual'

  const LocalizacaoCarregada({
    required this.latitude,
    required this.longitude,
    this.enderecoFormatado,
    this.referencia,
    required this.origem,
  });

  @override
  List<Object?> get props => [latitude, longitude, enderecoFormatado, referencia, origem];
}

class LocalizacaoNaoEncontrada extends LocalizacaoState {}
