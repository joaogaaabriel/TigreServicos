import 'package:app_serviceflow/tigreservicos/core/services/ServiceOrder.dart';
import 'package:app_serviceflow/tigreservicos/core/services/ServiceOrderLocalDatasource.dart';

/// ---------------------------------------------------------------------------
/// ServiceOrderRepository
/// ---------------------------------------------------------------------------
/// Responsável por atuar como camada de abstração entre a aplicação e a fonte
/// de dados local (LocalDataSource).
///
/// Essa classe segue o padrão Repository Pattern, onde:
/// - O Repository não sabe como os dados são armazenados
/// - Ele apenas delega as operações para o DataSource
///
/// Isso facilita manutenção, testes e futura expansão (ex: API remota).
/// ---------------------------------------------------------------------------
class ServiceOrderRepository {
  /// Construtor recebe a dependência do DataSource local.
  ServiceOrderRepository({required ServiceOrderLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  /// Fonte de dados local responsável pelas operações reais de persistência.
  final ServiceOrderLocalDataSource _localDataSource;

  // ---------------------------------------------------------------------------
  // READ - Buscar todas as ordens de serviço
  // ---------------------------------------------------------------------------
  /// Retorna todas as ordens armazenadas localmente.
  ///
  /// O Repository apenas repassa a chamada ao DataSource.
  Future<List<ServiceOrder>> getAll() {
    return _localDataSource.getAll();
  }

  // ---------------------------------------------------------------------------
  // CREATE - Salvar nova ordem de serviço
  // ---------------------------------------------------------------------------
  /// Persiste uma nova ordem de serviço.
  ///
  /// Observação:
  /// - Aqui chamamos `insert`, pois o DataSource controla a lógica interna
  ///   de armazenamento.
  Future<void> save(ServiceOrder order) {
    return _localDataSource.insert(order);
  }

  // ---------------------------------------------------------------------------
  // UPDATE - Atualizar ordem existente
  // ---------------------------------------------------------------------------
  /// Atualiza uma ordem de serviço já existente.
  ///
  /// O DataSource é responsável por localizar o item pelo ID e substituí-lo.
  Future<void> update(ServiceOrder order) {
    return _localDataSource.update(order);
  }

  // ---------------------------------------------------------------------------
  // DELETE - Remover ordem de serviço
  // ---------------------------------------------------------------------------
  /// Remove uma ordem de serviço pelo seu identificador.
  Future<void> delete(String id) {
    return _localDataSource.delete(id);
  }
}
