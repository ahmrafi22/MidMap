import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/map_entry.dart' as model;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('midmap.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(path, version: 1, onCreate: _createDB);
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE map_entries (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        image TEXT,
        cached_image_path TEXT
      )
    ''');
  }

  // Insert or update entry
  Future<void> insertEntry(
    model.MapEntry entry, {
    String? cachedImagePath,
  }) async {
    final db = await database;
    await db.insert('map_entries', {
      'id': entry.id,
      'title': entry.title,
      'lat': entry.lat,
      'lon': entry.lon,
      'image': entry.image,
      'cached_image_path': cachedImagePath,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert multiple entries
  Future<void> insertEntries(
    List<model.MapEntry> entries, {
    Map<int, String>? cachedImagePaths,
  }) async {
    final db = await database;
    final batch = db.batch();

    for (var entry in entries) {
      batch.insert('map_entries', {
        'id': entry.id,
        'title': entry.title,
        'lat': entry.lat,
        'lon': entry.lon,
        'image': entry.image,
        'cached_image_path': cachedImagePaths?[entry.id],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // Get all entries
  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final db = await database;
    return await db.query('map_entries', orderBy: 'id DESC');
  }

  // Get entry by ID
  Future<Map<String, dynamic>?> getEntryById(int id) async {
    final db = await database;
    final results = await db.query(
      'map_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Update entry
  Future<void> updateEntry(
    model.MapEntry entry, {
    String? cachedImagePath,
  }) async {
    final db = await database;
    await db.update(
      'map_entries',
      {
        'title': entry.title,
        'lat': entry.lat,
        'lon': entry.lon,
        'image': entry.image,
        'cached_image_path': cachedImagePath,
      },
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Delete entry
  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('map_entries', where: 'id = ?', whereArgs: [id]);
  }

  // Clear all entries
  Future<void> clearAllEntries() async {
    final db = await database;
    await db.delete('map_entries');
  }

  // Get cached image path for an entry
  Future<String?> getCachedImagePath(int id) async {
    final db = await database;
    final results = await db.query(
      'map_entries',
      columns: ['cached_image_path'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first['cached_image_path'] as String?;
    }
    return null;
  }

  // Update cached image path
  Future<void> updateCachedImagePath(int id, String cachedImagePath) async {
    final db = await database;
    await db.update(
      'map_entries',
      {'cached_image_path': cachedImagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
