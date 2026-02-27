
import '../models/enums.dart';
import '../models/loja_model.dart';

/// Abstração do repositório de lojas
abstract class LojaRepository {
  /// Busca lojas com filtros e ordenação
  Future<List<Loja>> getLojas({
    CategoriaTipo? categoria,
    String? busca,
    String? ordenarPor, // 'nota', 'distancia', 'entrega'
    bool? apenasAbertas,
    double? latitude,
    double? longitude,
  });

  /// Busca lojas em destaque
  Future<List<Loja>> getLojasDestaque();

  /// Busca uma loja específica por ID
  Future<Loja> getLojaById(int id);

  /// Busca categorias disponíveis
  Future<List<CategoriaTipo>> getCategorias();
}