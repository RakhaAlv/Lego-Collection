import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lego_catalog/models/lego_set.dart';
import 'package:lego_catalog/models/lego_theme.dart';
import 'package:lego_catalog/screens/compare_sets_screen.dart';
import 'package:lego_catalog/services/api_service.dart';
import 'package:lego_catalog/services/wishlist_store.dart';
import 'package:lego_catalog/utils/currency_formatter.dart';

class _FakeApiService extends ApiService {
  @override
  Future<List<LegoSet>> fetchSets({int? themeId}) async => const [
        LegoSet(
          id: 1,
          themeId: 1,
          setNumber: '76269',
          name: 'Avengers Tower',
          theme: 'LEGO Marvel',
          pieces: 5201,
          ageRating: '18+',
          releaseYear: 2023,
          dimensions: '90 cm x 34 cm x 25 cm',
          priceIdr: 8499000,
          imageUrl: 'http://10.0.2.2:8000/images/76269.png',
          description: 'Menara Avengers',
        ),
        LegoSet(
          id: 3,
          themeId: 1,
          setNumber: '76191',
          name: 'Infinity Gauntlet',
          theme: 'LEGO Marvel',
          pieces: 590,
          ageRating: '18+',
          releaseYear: 2021,
          dimensions: '31 cm x 13 cm x 11 cm',
          priceIdr: 1399000,
          imageUrl: 'http://10.0.2.2:8000/images/76191.webp',
          description: 'Sarung tangan Thanos',
        ),
      ];
}

void main() {
  test('CurrencyFormatter memformat Rupiah dan pemisah ribuan', () {
    expect(CurrencyFormatter.toRupiah(8499000), 'Rp 8.499.000');
    expect(CurrencyFormatter.toRupiah(199000), 'Rp 199.000');
    expect(CurrencyFormatter.thousands(5201), '5.201');
  });

  test('LegoSet.fromJson mem-parsing data Avengers Tower dari API', () {
    final s = LegoSet.fromJson({
      'id': 1,
      'theme_id': 1,
      'set_number': '76269',
      'name': 'Avengers Tower',
      'theme': 'LEGO Marvel',
      'pieces': 5201,
      'age_rating': '18+',
      'release_year': 2023,
      'dimensions': '90 cm x 34 cm x 25 cm',
      'price_idr': 8499000,
      'image_url': 'http://10.0.2.2:8000/images/76269.png',
      'description': 'Menara Avengers setinggi 90 cm',
    });
    expect(s.id, 1);
    expect(s.setNumber, '76269');
    expect(s.name, 'Avengers Tower');
    expect(s.pieces, 5201);
    expect(s.priceIdr, 8499000);
  });

  test('LegoTheme.fromJson mem-parsing data LEGO Marvel dari API', () {
    final t = LegoTheme.fromJson({
      'id': 1,
      'theme_name': 'LEGO Marvel',
      'established_year': 2012,
      'target_audience': 'Anak, Remaja & Dewasa (7+ hingga 18+)',
      'difficulty_level': 'Menengah - Tinggi',
      'total_sets_released': 250,
      'characteristic': 'Markas ikonik dan minifigure superhero',
      'image_url': 'http://10.0.2.2:8000/images/76269.png',
      'overview': 'Ringkasan LEGO Marvel',
    });
    expect(t.id, 1);
    expect(t.themeName, 'LEGO Marvel');
    expect(t.establishedYear, 2012);
    expect(t.totalSetsReleased, 250);
  });

  test('WishlistStore menyimpan, menghitung total, dan menghapus set', () {
    final store = WishlistStore.instance;
    store.clear();

    const tower = LegoSet(
      id: 1,
      themeId: 1,
      setNumber: '76269',
      name: 'Avengers Tower',
      theme: 'LEGO Marvel',
      pieces: 5201,
      ageRating: '18+',
      releaseYear: 2023,
      dimensions: '90 cm x 34 cm x 25 cm',
      priceIdr: 8499000,
      imageUrl: 'http://10.0.2.2:8000/images/76269.png',
      description: 'desc',
    );

    expect(store.toggle(tower), isTrue);
    expect(store.contains(1), isTrue);
    expect(store.count, 1);
    expect(store.totalPriceIdr, 8499000);

    expect(store.toggle(tower), isFalse);
    expect(store.isEmpty, isTrue);
    expect(store.totalPriceIdr, 0);
  });

  testWidgets('CompareSetsScreen menampilkan perbandingan 2 set dan harga per keping',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CompareSetsScreen(apiService: _FakeApiService()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bandingkan Set'), findsOneWidget);
    expect(find.text('Avengers Tower'), findsWidgets);
    expect(find.text('Infinity Gauntlet'), findsWidgets);
    expect(find.text('Harga / Keping'), findsOneWidget);
    expect(find.text('Rp 1.634 / pcs'), findsOneWidget);
    expect(find.text('Rp 2.371 / pcs'), findsOneWidget);
    expect(find.text('Lebih Hemat'), findsNWidgets(2));
    expect(find.text('Lebih Banyak'), findsOneWidget);
  });
}
