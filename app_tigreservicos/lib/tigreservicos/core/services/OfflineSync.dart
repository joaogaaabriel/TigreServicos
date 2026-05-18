import 'StorageService.dart';

/// Fila offline simplificada.
/// Neste momento ela so marca que existe algo para sincronizar no futuro.
class OfflineSync {
  OfflineSync({required this.storageService});

  final StorageService storageService;

  static const _syncQueueKey = 'sync_queue_size';

  Future<void> enqueue() async {
    final currentSize =
        int.tryParse(storageService.getString(_syncQueueKey) ?? '0') ?? 0;
    await storageService.setString(_syncQueueKey, '${currentSize + 1}');
  }
}
