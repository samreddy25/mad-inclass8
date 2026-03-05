import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, 'card_organizer.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL UNIQUE,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT NOT NULL,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY(folder_id) REFERENCES folders(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _seedData(Database db) async {
    final suits = ['clubs', 'diamonds', 'hearts', 'spades'];
    final ranks = [
      'ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king'
    ];

    final now = DateTime.now().toIso8601String();

    for (final suit in suits) {
      final folderId = await db.insert('folders', {
        'folder_name': suit, // stored lowercase
        'timestamp': now,
      });

      for (final rank in ranks) {
        final img = 'assets/cards/${rank}_of_${suit}.png';

        await db.insert('cards', {
          'card_name': rank,
          'suit': suit,
          'image_url': img,
          'folder_id': folderId,
        });
      }
    }
  }
}