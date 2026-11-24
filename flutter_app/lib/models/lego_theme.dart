import '../utils/currency_formatter.dart';

// Model data 1 tema LEGO dari respons JSON /api/themes.
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

  factory LegoTheme.fromJson(Map<String, dynamic> json) {
    return LegoTheme(
      id: CurrencyFormatter.parseInt(json['id']),
      themeName: '${json['theme_name'] ?? ''}',
      establishedYear: CurrencyFormatter.parseInt(json['established_year']),
      targetAudience: '${json['target_audience'] ?? ''}',
      difficultyLevel: '${json['difficulty_level'] ?? ''}',
      totalSetsReleased: CurrencyFormatter.parseInt(json['total_sets_released']),
      characteristic: '${json['characteristic'] ?? ''}',
      imageUrl: '${json['image_url'] ?? ''}',
      overview: '${json['overview'] ?? ''}',
    );
  }
}
