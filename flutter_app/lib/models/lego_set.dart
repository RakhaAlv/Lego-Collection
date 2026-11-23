class LegoSet {
  final int id;
  final int themeId;
  final String setNumber;
  final String name;
  final String theme;
  final int pieces;
  final String ageRating;
  final int releaseYear;
  final String dimensions;
  final int priceIdr;
  final String imageUrl;
  final String description;

  const LegoSet({
    required this.id,
    required this.themeId,
    required this.setNumber,
    required this.name,
    required this.theme,
    required this.pieces,
    required this.ageRating,
    required this.releaseYear,
    required this.dimensions,
    required this.priceIdr,
    required this.imageUrl,
    required this.description,
  });

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  factory LegoSet.fromJson(Map<String, dynamic> json) {
    return LegoSet(
      id: _toInt(json['id']),
      themeId: _toInt(json['theme_id']),
      setNumber: '${json['set_number'] ?? ''}',
      name: json['name'] ?? '',
      theme: json['theme'] ?? '',
      pieces: _toInt(json['pieces']),
      ageRating: json['age_rating'] ?? '',
      releaseYear: _toInt(json['release_year']),
      dimensions: json['dimensions'] ?? '',
      priceIdr: _toInt(json['price_idr']),
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
