/// ---------------------------------------------------------------------------
/// ServiceOrder
/// ---------------------------------------------------------------------------
/// Modelo de domínio que representa uma Ordem de Serviço no sistema.
///
/// Responsabilidades:
/// - Representar os dados da ordem de serviço
/// - Converter dados entre Map (DB/API) e objeto Dart
/// - Permitir criação de cópias imutáveis com `copyWith`
///
/// Esse modelo é utilizado em:
/// - SQLite (persistência local)
/// - API (serialização/deserialização)
/// - Camada de domínio (regras de negócio)
/// ---------------------------------------------------------------------------
class ServiceOrder {
  /// Identificador único da ordem de serviço
  final String id;

  /// Nome do cliente associado à ordem
  final String customerName;

  /// Descrição detalhada do serviço
  final String description;

  /// Status atual da ordem (ex: aberto, em andamento, concluído)
  final String status;

  /// Foto de entrada (base64 ou URL)
  final String? entryPhoto;

  /// Foto de saída (base64 ou URL)
  final String? exitPhoto;

  /// Assinatura do cliente ou técnico (base64)
  final String? signature;

  /// Data de criação da ordem
  final String createdAt;

  /// Construtor imutável da entidade
  const ServiceOrder({
    required this.id,
    required this.customerName,
    required this.description,
    required this.status,
    required this.createdAt,
    this.entryPhoto,
    this.exitPhoto,
    this.signature,
  });

  // ---------------------------------------------------------------------------
  // MAPPING - DATABASE / API
  // ---------------------------------------------------------------------------

  /// Constrói um objeto [ServiceOrder] a partir de um Map (JSON/DB).
  ///
  /// Usado principalmente para:
  /// - Leitura do SQLite
  /// - Resposta de API
  factory ServiceOrder.fromMap(Map<String, dynamic> map) {
    return ServiceOrder(
      id: map['id'] as String,
      customerName: map['customerName'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      createdAt: map['createdAt'] as String,
      entryPhoto: map['entryPhoto'] as String?,
      exitPhoto: map['exitPhoto'] as String?,
      signature: map['signature'] as String?,
    );
  }

  /// Converte o objeto [ServiceOrder] para Map.
  ///
  /// Usado principalmente para:
  /// - Persistência no SQLite
  /// - Envio para API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'entryPhoto': entryPhoto,
      'exitPhoto': exitPhoto,
      'signature': signature,
    };
  }

  // ---------------------------------------------------------------------------
  // IMMUTABILITY SUPPORT
  // ---------------------------------------------------------------------------

  /// Cria uma nova instância do objeto com alterações parciais.
  ///
  /// Isso mantém a imutabilidade do modelo, permitindo updates seguros.
  ///
  /// Exemplo:
  /// ```dart
  /// final updated = order.copyWith(status: "concluído");
  /// ```
  ServiceOrder copyWith({
    String? id,
    String? customerName,
    String? description,
    String? status,
    String? createdAt,
    String? entryPhoto,
    String? exitPhoto,
    String? signature,
  }) {
    return ServiceOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      entryPhoto: entryPhoto ?? this.entryPhoto,
      exitPhoto: exitPhoto ?? this.exitPhoto,
      signature: signature ?? this.signature,
    );
  }
}
