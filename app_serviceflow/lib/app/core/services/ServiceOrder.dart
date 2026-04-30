class ServiceOrder {
  final String id;
  final String customerName;
  final String description;
  final String status;
  final String? entryPhoto;
  final String? exitPhoto;
  final String? signature;
  final String createdAt;

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
