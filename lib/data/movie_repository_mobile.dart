import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/movie.dart';

class MovieRepository {
  static const _dbName = 'movies.db';
  static const _dbVersion = 1;
  static const _tableMovies = 'movies';

  Database? _db;

  Future<Database> _getDb() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableMovies (
            id TEXT PRIMARY KEY,
            imageUrl TEXT NOT NULL,
            title TEXT NOT NULL,
            genre TEXT NOT NULL,
            ageRating TEXT NOT NULL,
            durationMinutes INTEGER NOT NULL,
            score REAL NOT NULL,
            description TEXT NOT NULL,
            year INTEGER NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Future<List<Movie>> loadMovies() async {
    final db = await _getDb();
    final maps = await db.query(
      _tableMovies,
      orderBy: 'title COLLATE NOCASE',
    );

    return maps
        .map((m) => Movie.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> saveMovies(List<Movie> movies) async {
    final db = await _getDb();
    await db.transaction((txn) async {
      await txn.delete(_tableMovies);
      for (final movie in movies) {
        await txn.insert(
          _tableMovies,
          movie.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}

Future<MovieRepository> createMovieRepository() async {
  final repo = MovieRepository();
  await repo._getDb();
  return repo;
}
