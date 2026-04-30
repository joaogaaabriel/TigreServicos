import '../../core/models/BaseModel.dart';

enum ServiceOrderStatus { realized, justified }

/// Registro final salvo quando o tecnico conclui ou justifica a visita.
class ServiceOrderModel extends BaseModel {
  ServiceOrderModel({
    required super.id,
    required super.createdAt,
    required this.customerId,
    required this.customerName,
    required this.serviceName,
    required this.status,
    required this.date,
    this.entryPhotoBase64,
    this.exitPhotoBase64,
    this.signatureBase64,
    this.justification,
  });

  final String customerId;
  final String customerName;
  final String serviceName;
  final ServiceOrderStatus status;
  final DateTime date;
  final String? entryPhotoBase64;
  final String? exitPhotoBase64;
  final String? signatureBase64;
  final String? justification;

  bool get isRealized => status == ServiceOrderStatus.realized;
  bool get isJustified => status == ServiceOrderStatus.justified;

  factory ServiceOrderModel.fromMap(Map<String, dynamic> map) {
    return ServiceOrderModel(
      id: map['id'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? '',
      status: ServiceOrderStatus.values.firstWhere(
        (item) => item.name == map['status'],
        orElse: () => ServiceOrderStatus.justified,
      ),
      date: DateTime.parse(map['date'] as String),
      entryPhotoBase64: map['entryPhotoBase64'] as String?,
      exitPhotoBase64: map['exitPhotoBase64'] as String?,
      signatureBase64: map['signatureBase64'] as String?,
      justification: map['justification'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'serviceName': serviceName,
      'status': status.name,
      'date': date.toIso8601String(),
      'entryPhotoBase64': entryPhotoBase64,
      'exitPhotoBase64': exitPhotoBase64,
      'signatureBase64': signatureBase64,
      'justification': justification,
    };
  }
}
