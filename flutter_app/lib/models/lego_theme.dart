class LegoTheme {
  final int id;
  final String themeName;
  final int establishedYear;
  final String targetAudience;
  final String difficultyLevel;
  final int totalSetsReleased;
  final String characteristic;
  final String imageUrl;
  final String overview;

  const LegoTheme({
    required this.id,
    required this.themeName,
    required this.establishedYear,
    required this.targetAudience,
    required this.difficultyLevel,
    required this.totalSetsReleased,
    required this.characteristic,
    required this.imageUrl,
    required this.overview,
  });

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  factory LegoTheme.fromJson(Map<String, dynamic> json) {
    return LegoTheme(
      id: _toInt(json['id']),
      themeName: json['theme_name'] ?? '',
      establishedYear: _toInt(json['established_year']),
      targetAudience: json['target_audience'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? '',
      totalSetsReleased: _toInt(json['total_sets_released']),
      characteristic: json['characteristic'] ?? '',
      imageUrl: json['image_url'] ?? '',
      overview: json['overview'] ?? '',
    );
  }
}
