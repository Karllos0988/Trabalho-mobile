import 'package:flutter/material.dart';

import '../data/movie_repository.dart';
import '../models/movie.dart';

class MovieViewModel extends ChangeNotifier {
  final MovieRepository repository;

  MovieViewModel(this.repository);

  final List<Movie> _movies = [];
  String _searchQuery = '';

  List<Movie> get movies {
    if (_searchQuery.isEmpty) return List.unmodifiable(_movies);
    final query = _searchQuery.toLowerCase();
    return _movies
        .where(
          (m) =>
              m.title.toLowerCase().contains(query) ||
              m.genre.toLowerCase().contains(query),
        )
        .toList();
  }

  String get searchQuery => _searchQuery;

  Future<void> loadMovies() async {
    final loaded = await repository.loadMovies();
    _movies
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> _persist() async {
    await repository.saveMovies(_movies);
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> addMovie(Movie movie) async {
    _movies.add(movie);
    await _persist();
  }

  Future<void> updateMovie(Movie movie) async {
    final index = _movies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _movies[index] = movie;
      await _persist();
    }
  }

  Future<void> deleteMovie(String id) async {
    _movies.removeWhere((m) => m.id == id);
    await _persist();
  }

  Movie? getById(String id) {
    try {
      return _movies.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
