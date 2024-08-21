import 'package:bang_demo/data/models/cover.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CoverRepository {
  static final CoverRepository _instance = CoverRepository._internal();

  factory CoverRepository() => _instance;

  CoverRepository._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cover.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cover (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            borderRadius DOUBLE NOT NULL,
            color INTEGER NOT NULL,
            `constraint` TEXT NOT NULL,
            text TEXT NOT NULL,
            image TEXT NOT NULL
          );
        ''');
      },
    );
  }

  /// 插入数据，返回 id，id 存在则替换
  Future<int> insertCover(Cover cover) async {
    final db = await database;
    return db.insert(
      'cover',
      cover.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCover(Cover cover) async {
    final db = await database;
    return await db.update(
      'cover',
      cover.toSqlMap(),
      where: 'id = ?',
      whereArgs: [cover.id],
    );
  }

  Future<int> deleteCover(int id) async {
    final db = await database;
    return await db.delete(
      'cover',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Cover?> getCover(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> coverMaps = await db.query(
      'cover',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (coverMaps.isNotEmpty) {
      final coverMap = coverMaps.first;
      return Cover.fromSqlMap(coverMap);
    } else {
      return null;
    }
  }

  Future<List<Cover>> listCover() async {
    final db = await database;
    final List<Map<String, dynamic>> coverMaps = await db.query('cover');

    return List.generate(coverMaps.length, (i) {
      final coverMap = coverMaps[i];
      return Cover.fromSqlMap(coverMap);
    });
  }
}
