import '../../core/models/BaseModel.dart';

/// Modelo simples de usuario para cadastro/login local.
class UserModel extends BaseModel {
  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.token,
    required super.id,
    required super.createdAt,
  });

  final String name;
  final String email;
  final String password;
  final String token;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      token: map['token'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'name': name,
      'email': email,
      'password': password,
      'token': token,
    };
  }
}
