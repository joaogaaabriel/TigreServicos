import 'dart:convert';

import 'package:app_serviceflow/tigreservicos/core/models/BaseModel.dart';
import 'package:app_serviceflow/tigreservicos/core/services/StorageService.dart';

/// ---------------------------------------------------------------------------
/// BaseRepository
/// ---------------------------------------------------------------------------
/// Classe abstrata responsável por padronizar operações básicas de persistência
/// local (CRUD) utilizando um [StorageService].
///
/// Essa classe segue o padrão Base-Driven Architecture, permitindo que
/// qualquer repositório concreto implemente apenas o que é específico da entidade,
/// enquanto reutiliza toda a lógica comum de armazenamento.
///
/// Tipagem genérica:
/// - [T] deve estender [BaseModel], garantindo que toda entidade tenha um `id`
///   e suporte conversão para Map.
///
/// ---------------------------------------------------------------------------
abstract class BaseRepository<T extends BaseModel> {
  /// Construtor recebe o serviço de armazenamento local.
  BaseRepository({required StorageService storageService})
      : _storageService = storageService;

  /// Serviço responsável por persistência local (ex: SharedPreferences, Hive etc.)
  final StorageService _storageService;

  /// Chave utilizada para armazenar os dados no storage.
  /// Cada repositório concreto deve definir sua própria chave.
  String get storageKey;

  /// Converte um Map vindo do storage em um objeto do tipo [T].
  /// Deve ser implementado por cada repositório concreto.
  T fromMap(Map<String, dynamic> map);

  // ---------------------------------------------------------------------------
  // READ - Buscar todos os registros
  // ---------------------------------------------------------------------------
  /// Recupera todos os itens armazenados localmente.
  ///
  /// Fluxo:
  /// 1. Busca string JSON no storage
  /// 2. Verifica se existe conteúdo válido
  /// 3. Decodifica JSON em lista de mapas
  /// 4. Converte cada mapa para objeto [T]
  Future<List<T>> getAll() async {
    final jsonString = _storageService.getString(storageKey);

    // Se não houver dados salvos, retorna lista vazia
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    // Converte JSON string em lista dinâmica
    final list = (jsonDecode(jsonString) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    // Converte cada item para o tipo genérico T
    return list.map(fromMap).toList();
  }

  // ---------------------------------------------------------------------------
  // CREATE / UPDATE - Persistir lista inteira
  // ---------------------------------------------------------------------------
  /// Salva toda a lista de itens no storage.
  ///
  /// Observação:
  /// - Substitui completamente os dados anteriores.
  Future<void> saveAll(List<T> items) async {
    final encoded = jsonEncode(items.map((item) => item.toMap()).toList());

    await _storageService.setString(storageKey, encoded);
  }

  // ---------------------------------------------------------------------------
  // CREATE - Inserir novo item
  // ---------------------------------------------------------------------------
  /// Insere um novo item na lista persistida.
  ///
  /// Fluxo:
  /// 1. Recupera lista atual
  /// 2. Adiciona novo item
  /// 3. Salva novamente no storage
  Future<void> insert(T item) async {
    final items = await getAll();
    items.add(item);
    await saveAll(items);
  }

  // ---------------------------------------------------------------------------
  // UPDATE - Atualizar item existente
  // ---------------------------------------------------------------------------
  /// Atualiza um item existente com base no seu `id`.
  ///
  /// Regras:
  /// - Se o item não existir, ele será adicionado como novo.
  Future<void> update(T item) async {
    final items = await getAll();

    // Busca índice do item existente
    final index = items.indexWhere((current) => current.id == item.id);

    if (index == -1) {
      // Se não existir, adiciona novo
      items.add(item);
    } else {
      // Substitui o item existente
      items[index] = item;
    }

    await saveAll(items);
  }

  // ---------------------------------------------------------------------------
  // DELETE - Remover item
  // ---------------------------------------------------------------------------
  /// Remove um item da lista com base no seu `id`.
  Future<void> delete(String id) async {
    final items = await getAll();

    // Remove todos os itens com o id informado
    items.removeWhere((item) => item.id == id);

    await saveAll(items);
  }
}
