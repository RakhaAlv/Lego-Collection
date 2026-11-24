import '../utils/currency_formatter.dart';

// Model data 1 set LEGO dari respons JSON /api/sets.
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

  // Rasio harga per pcs untuk indikator Best Value di halaman Compare.
  int get pricePerPiece => pieces > 0 ? (priceIdr / pieces).round() : 0;

  factory LegoSet.fromJson(Map<String, dynamic> json) {
    return LegoSet(
      id: CurrencyFormatter.parseInt(json['id']),
      themeId: CurrencyFormatter.parseInt(json['theme_id']),
      setNumber: '${json['set_number'] ?? ''}',
      name: '${json['name'] ?? ''}',
      theme: '${json['theme'] ?? ''}',
      pieces: CurrencyFormatter.parseInt(json['pieces']),
      ageRating: '${json['age_rating'] ?? ''}',
      releaseYear: CurrencyFormatter.parseInt(json['release_year']),
      dimensions: '${json['dimensions'] ?? ''}',
      priceIdr: CurrencyFormatter.parseInt(json['price_idr']),
      imageUrl: '${json['image_url'] ?? ''}',
      description: '${json['description'] ?? ''}',
    );
  }
}
