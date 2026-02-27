import 'package:equatable/equatable.dart';
import '../../../models/enums.dart';
import '../../../models/loja_model.dart';

abstract class LojasState extends Equatable {
  const LojasState();

  @override
  List<Object> get props => [];
}

class LojasInitial extends LojasState {}

class LojasLoading extends LojasState {}

class LojasLoaded extends LojasState {
  final List<Loja> allLojas;
  final List<Loja> filteredLojas;
  final Set<CategoriaTipo> availableCategories;
  final Set<CategoriaTipo> selectedCategories;
  final OrdenacaoTipo ordenacaoAtual;

  const LojasLoaded({
    required this.allLojas,
    required this.filteredLojas,
    required this.availableCategories,
    required this.selectedCategories,
    this.ordenacaoAtual = OrdenacaoTipo.padrao,
  });

  LojasLoaded copyWith({
    List<Loja>? allLojas,
    List<Loja>? filteredLojas,
    Set<CategoriaTipo>? availableCategories,
    Set<CategoriaTipo>? selectedCategories,
    OrdenacaoTipo? ordenacaoAtual,
  }) {
    return LojasLoaded(
      allLojas: allLojas ?? this.allLojas,
      filteredLojas: filteredLojas ?? this.filteredLojas,
      availableCategories: availableCategories ?? this.availableCategories,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      ordenacaoAtual: ordenacaoAtual ?? this.ordenacaoAtual,
    );
  }

  @override
  List<Object> get props => [allLojas, filteredLojas, availableCategories, selectedCategories, ordenacaoAtual];
}

class LojasError extends LojasState {
  final String message;

  const LojasError(this.message);

  @override
  List<Object> get props => [message];
}
