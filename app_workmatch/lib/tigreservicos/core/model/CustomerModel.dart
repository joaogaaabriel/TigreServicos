class CustomerModel {
  final String id;
  final String name;
  final String serviceName;

  CustomerModel({
    required this.id,
    required this.name,
    required this.serviceName,
  });

  String get initials {
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }
}
