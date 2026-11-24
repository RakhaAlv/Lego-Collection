import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lego_catalog/models/lego_set.dart';
import 'package:lego_catalog/models/lego_theme.dart';
import 'package:lego_catalog/screens/compare_sets_screen.dart';
import 'package:lego_catalog/screens/home_screen.dart';
import 'package:lego_catalog/screens/main_navigation.dart';
import 'package:lego_catalog/screens/profile_about_screen.dart';
import 'package:lego_catalog/screens/set_detail_screen.dart';
import 'package:lego_catalog/screens/sets_list_screen.dart';
import 'package:lego_catalog/services/api_service.dart';
import 'package:lego_catalog/services/wishlist_store.dart';
import 'package:lego_catalog/utils/currency_formatter.dart';

// Unit & widget tests utama aplikasi LEGO COLLECTION.
class _FakeApiService extends ApiService {
  static const List<LegoSet> _sampleSets = [
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
      imageUrl: 'http://localhost:8000/images/76269.png',
      description: 'Standing 90 cm tall, this monumental Avengers Tower collector build.',
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
      imageUrl: 'http://localhost:8000/images/76191.webp',
      description: 'Collector display recreation of the iconic golden Infinity Gauntlet.',
    ),
  ];

  @override
  Future<List<LegoTheme>> fetchThemes() async => const [
    LegoTheme(
      id: 1,
      themeName: 'LEGO Marvel',
      establishedYear: 2012,
      targetAudience: 'Ages 7+ to 18+',
      difficultyLevel: 'Intermediate to Advanced',
      totalSetsReleased: 250,
      characteristic: 'Marvel Super Heroes',
      imageUrl: 'http://localhost:8000/images/76269.png',
      overview: 'LEGO Marvel overview.',
    ),
  ];

  @override
  Future<List<LegoSet>> fetchSets({int? themeId}) async => _sampleSets;

  @override
  Future<LegoSet> fetchSetById(int id) async => _sampleSets.firstWhere(
    (s) => s.id == id,
    orElse: () => _sampleSets.first,
  );
}

void main() {
  test(
    'CurrencyFormatter & SafeDisplayString format numbers and guard nulls',
    () {
      expect(CurrencyFormatter.toRupiah(8499000), 'Rp 8.499.000');
      expect(CurrencyFormatter.toRupiah(199000), 'Rp 199.000');
      expect(CurrencyFormatter.thousands(5201), '5.201');
      expect(CurrencyFormatter.shortTheme('LEGO Marvel'), 'MARVEL');
      expect(CurrencyFormatter.shortTheme('LEGO City'), 'LEGO CITY');
      expect((null as String?).orPlaceholder(), '-');
      expect('null'.orPlaceholder('N/A'), 'N/A');
    },
  );

  test('LegoSet.fromJson parses payload and computes pricePerPiece', () {
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
      'image_url': 'http://localhost:8000/images/76269.png',
      'description': 'Avengers Tower collector build',
    });
    expect(s.id, 1);
    expect(s.setNumber, '76269');
    expect(s.pricePerPiece, 1634);
  });

  test('WishlistStore toggles, totals, and clears sets', () {
    final store = WishlistStore.instance;
    store.clear();

    final tower = _FakeApiService._sampleSets.first;
    expect(store.toggle(tower), isTrue);
    expect(store.contains(1), isTrue);
    expect(store.count, 1);
    expect(store.totalPriceIdr, 8499000);

    expect(store.toggle(tower), isFalse);
    expect(store.isEmpty, isTrue);
  });

  testWidgets(
    'HomeScreen renders LEGO COLLECTION hero carousel & COLLECTOR EDITION',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(apiService: _FakeApiService())),
      );
      await tester.pumpAndSettle();

      expect(find.text('LEGO COLLECTION'), findsWidgets);
      expect(find.text('AVENGERS TOWER'), findsWidgets);
      expect(find.text('EXPLORE CATALOG'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -650));
      await tester.pumpAndSettle();

      expect(find.text('COLLECTOR EDITION'), findsOneWidget);
    },
  );

  testWidgets(
    'SetsListScreen renders vertical GridView with AGE rating badges',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SetsListScreen(apiService: _FakeApiService())),
      );
      await tester.pumpAndSettle();

      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('SORT: DEFAULT'), findsOneWidget);
      expect(find.text('AVENGERS TOWER'), findsOneWidget);
      expect(find.text('AGE 18+'), findsWidgets);
      expect(find.byType(GridView), findsOneWidget);
    },
  );

  testWidgets('CompareSetsScreen renders side-by-side sets without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CompareSetsScreen(apiService: _FakeApiService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('COMPARE SETS'), findsOneWidget);
    expect(find.text('Price / Piece'), findsOneWidget);
    expect(find.text('Rp 1.634 / pcs'), findsOneWidget);
    expect(find.text('Rp 2.371 / pcs'), findsOneWidget);
    expect(find.text('BEST VALUE'), findsNWidgets(2));
    expect(find.text('MORE PIECES'), findsOneWidget);
  });

  testWidgets(
    'SetDetailScreen uses English labels & MainNavigation keeps Bottom Navbar visible',
    (tester) async {
      final fakeApi = _FakeApiService();
      await tester.pumpWidget(
        MaterialApp(home: MainNavigation(apiService: fakeApi)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('VIEW SET').first);
      await tester.pumpAndSettle();

      expect(find.text('TOTAL PIECES'), findsOneWidget);
      expect(find.text('AGE RATING'), findsOneWidget);
      expect(find.text('RELEASE YEAR'), findsOneWidget);
      expect(find.text('DIMENSIONS'), findsOneWidget);
      expect(find.text('PRODUCT DESCRIPTION'), findsOneWidget);
      expect(find.text('SAVE TO WISHLIST'), findsOneWidget);

      // Bottom Navigation Bar harus tetap terlihat di halaman Detail.
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);

      await tester.tap(find.text('PROFILE'));
      await tester.pumpAndSettle();

      expect(find.text('LEGO INSIDERS'), findsOneWidget);
      expect(find.byType(SetDetailScreen), findsNothing);
    },
  );

  testWidgets('ProfileAboutScreen displays brickifyme avatar & LEGO Insiders', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileAboutScreen()));
    await tester.pumpAndSettle();

    expect(find.text('LEGO INSIDERS'), findsOneWidget);
    expect(find.text('Rakha Aljiva Prabaswara'), findsOneWidget);
    expect(find.text('21120124140126'), findsOneWidget);

    final avatarFinder = find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is ResizeImage &&
          ((w.image as ResizeImage).imageProvider as NetworkImage).url ==
              ProfileAboutScreen.profileAvatarUrl,
    );
    expect(avatarFinder, findsOneWidget);
  });
}
