import 'package:equatable/equatable.dart';
import '../../loja_home/models/pagination_model.dart';
import 'filter_option_model.dart';
import 'loja.dart';

class LojaResponseModel extends Equatable {
  final List<Loja> items;
  final PaginationModel pagination;
  final FilterOptionsModel filterOptions;

  const LojaResponseModel({
    required this.items,
    required this.pagination,
    required this.filterOptions,
  });

  factory LojaResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LojaResponseModel(
      items: (data['items'] as List? ?? [])
          .map((item) => Loja.fromJson(item))
          .toList(),
      pagination: PaginationModel.fromJson(data['pagination'] ?? {}),
      filterOptions: FilterOptionsModel.fromJson(data['filter_options'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [items, pagination, filterOptions];
}
