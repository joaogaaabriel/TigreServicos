import 'storage_service.dart';

/// O nome fala "database", mas por enquanto a implementacao esta simplificada.
/// A ideia e deixar um ponto unico para trocar shared_preferences por SQLite depois.
class DatabaseHelper {
  DatabaseHelper({required this.storageService});

  final StorageService storageService;
}
