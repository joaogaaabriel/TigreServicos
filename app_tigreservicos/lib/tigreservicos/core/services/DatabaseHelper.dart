import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// ---------------------------------------------------------------------------
/// DatabaseHelper
/// ---------------------------------------------------------------------------
/// Classe responsável por gerenciar a instância do banco de dados SQLite
/// da aplicação.
///
/// Implementa o padrão Singleton para garantir:
/// - Apenas uma instância do banco na aplicação
/// - Evitar múltiplas conexões abertas simultaneamente
///
/// Responsabilidades:
/// - Inicializar o banco
/// - Criar tabelas na primeira execução
/// - Fornecer acesso global ao Database
///
/// Usa o pacote `sqflite` para persistência local.
/// ---------------------------------------------------------------------------
class DatabaseHelper {
  /// Construtor privado para impedir múltiplas instâncias.
  DatabaseHelper._init();

  /// Instância única global (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// Instância do banco de dados (cache em memória)
  static Database? _database;

  // ---------------------------------------------------------------------------
  // GET DATABASE
  // ---------------------------------------------------------------------------
  /// Retorna a instância do banco de dados.
  ///
  /// Fluxo:
  /// 1. Se já existe instância aberta, retorna ela
  /// 2. Caso contrário, inicializa o banco
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app.db');
    return _database!;
  }

  // ---------------------------------------------------------------------------
  // INITIALIZATION
  // ---------------------------------------------------------------------------
  /// Inicializa o banco de dados SQLite no dispositivo.
  ///
  /// Parâmetros:
  /// - [filePath]: nome do arquivo do banco
  ///
  /// Responsável por:
  /// - Definir caminho físico do banco
  /// - Abrir conexão
  /// - Definir versão do schema
  /// - Registrar callback de criação
  Future<Database> _initDB(String filePath) async {
    // Caminho padrão de armazenamento do SQLite no dispositivo
    final dbPath = await getDatabasesPath();

    // Monta caminho completo do arquivo .db
    final path = join(dbPath, filePath);

    // Abre ou cria o banco de dados
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // ---------------------------------------------------------------------------
  // DATABASE SCHEMA
  // ---------------------------------------------------------------------------
  /// Cria as tabelas do banco de dados na primeira execução.
  ///
  /// Esse método é chamado automaticamente quando:
  /// - O banco ainda não existe
  /// - Ou quando a versão do banco muda (migration futura)
  Future<void> _createDB(Database db, int version) async {
    // -----------------------------------------------------------------------
    // Tabela: service_orders
    // -----------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE service_orders (
        id TEXT PRIMARY KEY,
        createdAt TEXT,
        customerId TEXT,
        customerName TEXT,
        serviceName TEXT,
        status TEXT,
        date TEXT,
        entryPhotoBase64 TEXT,
        exitPhotoBase64 TEXT,
        signatureBase64 TEXT,
        justification TEXT
      )
    ''');

    // -----------------------------------------------------------------------
    // Tabela: users
    // -----------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        token TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }
}