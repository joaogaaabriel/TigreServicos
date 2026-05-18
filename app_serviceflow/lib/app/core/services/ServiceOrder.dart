class ServiceOrder {
  final String id;
  final String createdAt;

  final String? customerId;
  final String customerName;

  final String serviceName;
  final String status;

  final String? date;

  final String? entryPhotoBase64;
  final String? exitPhotoBase64;

  final String? signatureBase64;

  final String? justification;

  const ServiceOrder({
    required this.id,
    required this.createdAt,
    required this.customerName,
    required this.serviceName,
    required this.status,
    this.customerId,
    this.date,
    this.entryPhotoBase64,
    this.exitPhotoBase64,
    this.signatureBase64,
    this.justification,
  });

  factory ServiceOrder.fromMap(Map<String, dynamic> map) {
    return ServiceOrder(
      id: map['id'] as String,
      createdAt: map['createdAt'] as String,

      customerId: map['customerId'] as String?,
      customerName: map['customerName'] as String,

      serviceName: map['serviceName'] as String,
      status: map['status'] as String,

      date: map['date'] as String?,

      entryPhotoBase64: map['entryPhotoBase64'] as String?,
      exitPhotoBase64: map['exitPhotoBase64'] as String?,

      signatureBase64: map['signatureBase64'] as String?,

      justification: map['justification'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,

      'customerId': customerId,
      'customerName': customerName,

      'serviceName': serviceName,
      'status': status,

      'date': date,

      'entryPhotoBase64': entryPhotoBase64,
      'exitPhotoBase64': exitPhotoBase64,

      'signatureBase64': signatureBase64,

      'justification': justification,
    };
  }

  ServiceOrder copyWith({
    String? id,
    String? createdAt,
    String? customerId,
    String? customerName,
    String? serviceName,
    String? status,
    String? date,
    String? entryPhotoBase64,
    String? exitPhotoBase64,
    String? signatureBase64,
    String? justification,
  }) {
    return ServiceOrder(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,

      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,

      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,

      date: date ?? this.date,

      entryPhotoBase64:
      entryPhotoBase64 ?? this.entryPhotoBase64,

      exitPhotoBase64:
      exitPhotoBase64 ?? this.exitPhotoBase64,

      signatureBase64:
      signatureBase64 ?? this.signatureBase64,

      justification:
      justification ?? this.justification,
    );
  }
}