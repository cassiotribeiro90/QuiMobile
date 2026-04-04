import 'package:equatable/equatable.dart';

class FilterOptionModel extends Equatable {
  final String value;
  final String label;
  final int count;

  const FilterOptionModel({
    required this.value,
    required this.label,
    required this.count,
  });

  factory FilterOptionModel.fromJson(Map<String, dynamic> json) {
    return FilterOptionModel(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [value, label, count];
}

class FilterOptionsModel extends Equatable {
  final List<FilterOptionModel> categorias;

  const FilterOptionsModel({required this.categorias});

  factory FilterOptionsModel.fromJson(Map<String, dynamic> json) {
    return FilterOptionsModel(
      categorias: (json['categorias'] as List? ?? [])
          .map((item) => FilterOptionModel.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [categorias];
}
