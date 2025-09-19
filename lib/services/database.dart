import 'dart:io';

import 'package:bruning/models/product.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'favorites.db');

    print('DB: Database path: $path');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    print('DB: Creating "favorites" table.');
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY,
        title TEXT,
        price REAL,
        thumbnail TEXT
      )
    ''');
  }

  Future<bool> toggleFavorite(Product product) async {
    final db = await database;
    final existing = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (existing.isNotEmpty) {
      print('DB: Removing product ID ${product.id} from favorites.');
      await db.delete('favorites', where: 'id = ?', whereArgs: [product.id]);
      return false;
    } else {
      print('DB: Adding product ID ${product.id} to favorites.');
      await db.insert('favorites', product.toJson());
      return true;
    }
  }

  Future<List<int>> getFavoriteIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    print('DB: Found ${maps.length} favorite product IDs.');

    return List.generate(maps.length, (i) => maps[i]['id'] as int);
  }
}
