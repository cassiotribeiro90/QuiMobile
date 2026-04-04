import 'package:equatable/equatable.dart';

class PaginationModel extends Equatable {
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  const PaginationModel({
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [total, page, perPage, totalPages];
}
