import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

class MovieRepository {
  static const _storageKey = 'movies_db';

  final SharedPreferences prefs;

  MovieRepository(this.prefs);

  Future<List<Movie>> loadMovies() async {
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMovies(List<Movie> movies) async {
    final encoded =
        json.encode(movies.map((movie) => movie.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}

Future<MovieRepository> createMovieRepository() async {
  final prefs = await SharedPreferences.getInstance();
  return MovieRepository(prefs);
}
