import 'dart:convert';

import '../models/base_model.dart';
import '../services/storage_service.dart';

/// Repositorio base para CRUD local em cima do storage.
/// Nao e um banco de verdade ainda, mas a assinatura ja deixa a troca futura mais tranquila.
abstract class BaseRepository<T extends BaseModel> {
  BaseRepository({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  String get storageKey;

  T fromMap(Map<String, dynamic> map);

  Future<List<T>> getAll() async {
    final jsonString = _storageService.getString(storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final list = (jsonDecode(jsonString) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    return list.map(fromMap).toList();
  }

  Future<void> saveAll(List<T> items) async {
    final encoded = jsonEncode(items.map((item) => item.toMap()).toList());
    await _storageService.setString(storageKey, encoded);
  }

  Future<void> insert(T item) async {
    final items = await getAll();
    items.add(item);
    await saveAll(items);
  }

  Future<void> update(T item) async {
    final items = await getAll();
    final index = items.indexWhere((current) => current.id == item.id);

    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }

    await saveAll(items);
  }

  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((item) => item.id == id);
    await saveAll(items);
  }
}
