/// BaseModel obriga nossas entidades a seguirem um contrato minimo.
/// Isso ajuda a manter o projeto previsivel quando mais telas forem surgindo.
abstract class BaseModel {
  BaseModel({
    this.id,
    this.createdAt,
  });

  final String? id;
  final DateTime? createdAt;

  Map<String, dynamic> toMap();
}
