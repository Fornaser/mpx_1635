import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mpx_1635/models/playlist_model.dart';

class PlaylistRepository {
  static const _dbName = 'playlist_database.db';
  static const _tableName = 'playlists';
  static Database? _db;

  static Future<Database> _database() async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            title TEXT,
            mediatype TEXT,
            media TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<void> insert({required Playlist playlist}) async {
    final db = await _database();
    await db.insert(
      _tableName,
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Playlist>> getPlaylists() async {
    final db = await _database();
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      final mediaRaw = jsonDecode(maps[i]['media']); 
      final List<Map<String, String>> mediaList = mediaRaw.map<Map<String, String>>((item) {
        if (item is String) {
          return {'id': item, 'title': item}; 
        } else if (item is Map) {
          return Map<String, String>.from(item);
        } else {
          throw Exception("Unknown media item format: $item");
        }
      }).toList();

      return Playlist(
        id: maps[i]['id'] as int?,
        title: maps[i]['title'] as String,
        mediatype: maps[i]['mediatype'] as String,
        media: mediaList,
        date: DateTime.parse(maps[i]['date'] as String),
      );
    });
  }


  static Future<void> update({required Playlist playlist}) async {
    final db = await _database();
    await db.update(
      _tableName,
      playlist.toMap(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  static Future<void> delete({required Playlist playlist}) async {
    final db = await _database();
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }
}
