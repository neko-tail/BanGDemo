import 'package:bang_demo/data/models/setting.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SettingRepository {
  static final SettingRepository _instance = SettingRepository._internal();

  factory SettingRepository() => _instance;

  SettingRepository._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 默认设置为 0，用户设置为 1
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'setting.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.transaction((txn) async {
          await txn.execute('''
          CREATE TABLE setting (
            id INTEGER PRIMARY KEY,
            autoStart BOOLEAN NOT NULL,
            gesture TEXT NOT NULL
          );
        ''');
          await txn.execute('''
          INSERT INTO setting (id, autoStart, gesture) 
          VALUES (0, 1, '{"tap": 0, "doubleTap": 1, "tripleTap": 2, "longPress": 0}');
        ''');
          await txn.execute('''
          INSERT INTO setting (id, autoStart, gesture) 
          VALUES (1, 1, '{"tap": 0, "doubleTap": 1, "tripleTap": 2, "longPress": 0}');
        ''');
        });
      },
    );
  }

  Future<Setting> getSetting() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'setting',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) {
      throw Exception('Setting not found');
    }

    return Setting.fromSqlMap(maps.first);
  }

  Future<int> updateSetting(Setting setting) async {
    final db = await database;
    return await db.update(
      'setting',
      setting.toSqlMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  /// 重置为默认设置
  Future<int> resetDefault() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'setting',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) {
      throw Exception('Setting not found');
    }

    return await db.update(
      'setting',
      maps.first,
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
