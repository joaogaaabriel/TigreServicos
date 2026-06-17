abstract class BaseModel {
  BaseModel({
    this.id,
    this.createdAt,
  });

  final String? id;
  final DateTime? createdAt;

  Map<String, dynamic> toMap();
}
