import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  static const _dbName = 'contacts.db';
  static const _dbVersion = 1;
  static const _table = 'contacts';

  Database? _db;

  // Opens the database once, then reuses it
  Future<Database> get _openDb async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          name        TEXT    NOT NULL,
          phone       TEXT    NOT NULL,
          email       TEXT,
          address     TEXT,
          company     TEXT,
          notes       TEXT,
          avatar_path TEXT,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          created_at  TEXT    NOT NULL
        )
      '''),
    );
  }

  Future<int> insertContact(Contact contact) async {
    final db = await _openDb;
    return db.insert(_table, contact.toMap());
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await _openDb;
    final rows = await db.query(_table, orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Contact.fromMap).toList();
  }

  Future<List<Contact>> getFavorites() async {
    final db = await _openDb;
    final rows = await db.query(
      _table,
      where: 'is_favorite = 1',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Contact.fromMap).toList();
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await _openDb;
    final q = '%$query%';
    final rows = await db.query(
      _table,
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Contact.fromMap).toList();
  }

  Future<void> updateContact(Contact contact) async {
    final db = await _openDb;
    await db.update(
      _table,
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await _openDb;
    await db.update(
      _table,
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteContact(int id) async {
    final db = await _openDb;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
