class Movie {
  final String id;
  String imageUrl;
  String title;
  String genre;
  String ageRating; // Livre, 10, 12, 14, 16, 18
  int durationMinutes;
  double score; // 0–5
  String description;
  int year;

  Movie({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.genre,
    required this.ageRating,
    required this.durationMinutes,
    required this.score,
    required this.description,
    required this.year,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      genre: json['genre'] as String,
      ageRating: json['ageRating'] as String,
      durationMinutes: json['durationMinutes'] as int,
      score: (json['score'] as num).toDouble(),
      description: json['description'] as String,
      year: json['year'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'genre': genre,
      'ageRating': ageRating,
      'durationMinutes': durationMinutes,
      'score': score,
      'description': description,
      'year': year,
    };
  }
}
