// lib/modules/carrinho/bloc/carrinho_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/carrinho_item.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../services/carrinho_service.dart';

abstract class CarrinhoState extends Equatable {
  const CarrinhoState();
  @override
  List<Object?> get props => [];
}

class CarrinhoInitial extends CarrinhoState {}

class CarrinhoLoading extends CarrinhoState {}

class CarrinhoLoaded extends CarrinhoState {
  final List<CarrinhoItem> itens;
  final int totalItens;
  final double subtotal;
  final String? lojaNome;

  const CarrinhoLoaded({
    required this.itens,
    required this.totalItens,
    required this.subtotal,
    this.lojaNome,
  });

  @override
  List<Object?> get props => [itens, totalItens, subtotal, lojaNome];
}

class CarrinhoError extends CarrinhoState {
  final String message;
  const CarrinhoError(this.message);
  @override
  List<Object> get props => [message];
}

class CarrinhoCubit extends Cubit<CarrinhoState> {
  final CarrinhoService _service;
  final AuthCubit _authCubit;
  StreamSubscription? _authSubscription;

  Map<int, CarrinhoItem> _itensMap = {};
  bool _isFetching = false;

  // Sistema de debounce para atualizações
  Timer? _updateDebounce;
  Map<int, int> _pendingUpdates = {}; // itemId -> quantidade pendente

  CarrinhoCubit(this._service, this._authCubit) : super(CarrinhoInitial()) {
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        print('🛒 [CarrinhoCubit] Autenticado, carregando carrinho...');
        carregarCarrinho();
      } else if (authState is AuthUnauthenticated) {
        print('🛒 [CarrinhoCubit] Desautenticado, limpando carrinho...');
        _limparEstado();
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _updateDebounce?.cancel();
    return super.close();
  }

  void _limparEstado() {
    _itensMap = {};
    _pendingUpdates.clear();
    _updateDebounce?.cancel();
    emit(const CarrinhoLoaded(itens: [], totalItens: 0, subtotal: 0));
  }

  Future<void> carregarCarrinho() async {
    if (_isFetching) return;

    if (_authCubit.state is! AuthAuthenticated) {
      print('🛒 [CarrinhoCubit] Não autenticado, ignorando carregamento');
      return;
    }

    _isFetching = true;
    if (state is! CarrinhoLoaded) {
      emit(CarrinhoLoading());
    }

    try {
      final response = await _service.carregarCarrinho();
      _updateItensMap(response.itens);

      emit(CarrinhoLoaded(
        itens: response.itens,
        totalItens: response.resumo.totalItens,
        subtotal: response.resumo.subtotal,
        lojaNome: response.resumo.lojaNome,
      ));
    } catch (e) {
      print('❌ [CarrinhoCubit] Erro ao carregar: $e');
      _limparEstado();
    } finally {
      _isFetching = false;
    }
  }

  Future<bool> adicionarItemSimples({
    required int produtoId,
    required int lojaId,
    required String nome,
    String? imagem,
    required double preco,
    int quantidade = 1,
  }) async {
    if (_authCubit.state is! AuthAuthenticated) {
      print('🛒 [CarrinhoCubit] Tentativa de adicionar item sem autenticação');
      throw Exception('Usuário não autenticado');
    }

    if (_isFetching) return false;
    _isFetching = true;

    try {
      final response = await _service.adicionarItem(
        produtoId: produtoId,
        quantidade: quantidade,
      );

      _updateItensMap(response.itens);

      emit(CarrinhoLoaded(
        itens: response.itens,
        totalItens: response.resumo.totalItens,
        subtotal: response.resumo.subtotal,
        lojaNome: response.resumo.lojaNome,
      ));

      return true;
    } catch (e) {
      print('❌ [CarrinhoCubit] Erro ao adicionar: $e');
      return false;
    } finally {
      _isFetching = false;
    }
  }

  // ✅ NOVA VERSÃO COM DEBOUNCE (usando copyWith)
  Future<void> atualizarQuantidade(int itemId, int quantidade) async {
    if (_isFetching) return;

    // Atualiza o mapa local imediatamente (UI responsiva)
    _pendingUpdates[itemId] = quantidade;
    _atualizarEstadoLocal(itemId, quantidade);

    // Cancela o timer anterior
    _updateDebounce?.cancel();

    // Agenda a atualização no servidor após 800ms de inatividade
    _updateDebounce = Timer(const Duration(milliseconds: 800), () {
      _enviarAtualizacoesPendentes();
    });
  }

  void _atualizarEstadoLocal(int itemId, int quantidade) {
    final itemAntigo = _itensMap[itemId];
    if (itemAntigo == null) return;

    // ✅ Usa o copyWith para criar um novo item com a quantidade atualizada
    _itensMap[itemId] = itemAntigo.copyWith(quantidade: quantidade);

    _emitirEstadoAtualizado();
  }

  void _emitirEstadoAtualizado() {
    final itens = _itensMap.values.toList();
    final totalItens = itens.fold<int>(0, (sum, item) => sum + item.quantidade);
    final subtotal = itens.fold<double>(0, (sum, item) => sum + item.precoTotal);

    final currentState = state;
    final lojaNome = currentState is CarrinhoLoaded ? currentState.lojaNome : null;

    emit(CarrinhoLoaded(
      itens: itens,
      totalItens: totalItens,
      subtotal: subtotal,
      lojaNome: lojaNome,
    ));
  }

  Future<void> _enviarAtualizacoesPendentes() async {
    if (_pendingUpdates.isEmpty) return;

    // Pega a última atualização pendente para cada item
    final updates = Map<int, int>.from(_pendingUpdates);
    _pendingUpdates.clear();

    _isFetching = true;

    try {
      // Envia cada atualização pendente
      for (var entry in updates.entries) {
        await _service.atualizarQuantidade(
          itemId: entry.key,
          quantidade: entry.value,
        );
      }

      // Recarrega o carrinho para garantir sincronia total
      await _syncCarrinho();
    } catch (e) {
      print('❌ [CarrinhoCubit] Erro ao enviar atualizações: $e');
      // Em caso de erro, recarrega o carrinho para restaurar estado correto
      await carregarCarrinho();
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _syncCarrinho() async {
    try {
      final response = await _service.carregarCarrinho();
      _updateItensMap(response.itens);

      emit(CarrinhoLoaded(
        itens: response.itens,
        totalItens: response.resumo.totalItens,
        subtotal: response.resumo.subtotal,
        lojaNome: response.resumo.lojaNome,
      ));
    } catch (e) {
      print('❌ [CarrinhoCubit] Erro ao sincronizar: $e');
    }
  }

  Future<void> removerItem(int itemId) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final response = await _service.removerItem(itemId: itemId);

      _updateItensMap(response.itens);

      emit(CarrinhoLoaded(
        itens: response.itens,
        totalItens: response.resumo.totalItens,
        subtotal: response.resumo.subtotal,
        lojaNome: response.resumo.lojaNome,
      ));
    } catch (e) {
      print('❌ [CarrinhoCubit] Erro ao remover item: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> limparCarrinho() async {
    _limparEstado();
    await carregarCarrinho();
  }

  void _updateItensMap(List<CarrinhoItem> itens) {
    _itensMap = {
      for (var item in itens) item.produtoId: item // ✅ CORRETO: Mapeia pelo ID do item no carrinho
    };
  }

  // Métodos auxiliares para UI
  bool estaNoCarrinho(int produtoId) {
    return _itensMap.values.any((item) => item.produtoId == produtoId);
  }

  int getQuantidade(int produtoId) {
    final item = _itensMap.values.firstWhere(
          (item) => item.produtoId == produtoId,
      orElse: () => CarrinhoItem(
        id: 0,
        produtoId: 0,
        nome: '',
        quantidade: 0,
        precoUnitario: 0,
        precoAdicionais: 0,
        precoTotal: 0,
      ),
    );
    return item.quantidade;
  }

  int? getItemId(int produtoId) {
    final item = _itensMap.values.firstWhere(
          (item) => item.produtoId == produtoId,
      orElse: () => CarrinhoItem(
        id: 0,
        produtoId: 0,
        nome: '',
        quantidade: 0,
        precoUnitario: 0,
        precoAdicionais: 0,
        precoTotal: 0,
      ),
    );
    return item.id != 0 ? item.id : null;
  }

  CarrinhoItem? getItemPorProduto(int produtoId) {
    return _itensMap.values.firstWhere(
          (item) => item.produtoId == produtoId,
      orElse: () => CarrinhoItem(
        id: 0,
        produtoId: 0,
        nome: '',
        quantidade: 0,
        precoUnitario: 0,
        precoAdicionais: 0,
        precoTotal: 0,
      ),
    );
  }
}