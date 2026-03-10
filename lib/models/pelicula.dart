class Pelicula {
  final int id;
  final String title;
  final String description;
  final int year;
  final String imageUrl;
  final String genre;
  final double stars;

  Pelicula({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    required this.imageUrl,
    required this.genre,
    required this.stars,
  });

  // Convierte un mapa JSON en un objeto Pelicula.
  factory Pelicula.fromJson(Map<String, dynamic> json) {
    return Pelicula(
      id:          json['id'],
      title:       json['title'],
      description: json['description'],
      year:        json['year'],
      imageUrl:    json['image_url'],
      genre:       json['genre'],
      stars:       (json['stars'] as num).toDouble(), // Puede venir como int o double.
    );
  }
}
