import '../../core/models/BaseModel.dart';

/// Cliente mockado do dia.
/// Como a necessidade atual e listagem fixa, manter assim deixa o fluxo bem direto.
class CustomerModel extends BaseModel {
  CustomerModel({
    required super.id,
    required super.createdAt,
    required this.name,
    required this.serviceName,
  });

  final String name;
  final String serviceName;

  String get initials {
    final parts = name.split(' ').where((item) => item.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'name': name,
      'serviceName': serviceName,
    };
  }
}
