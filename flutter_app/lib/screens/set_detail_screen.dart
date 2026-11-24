import 'package:flutter/material.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../services/api_service.dart';
import '../services/wishlist_store.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lego_set_card.dart';

class SetDetailScreen extends StatefulWidget {
  final int setId;
  final LegoSet? initialSet;
  final ApiService? apiService;

  const SetDetailScreen({
    super.key,
    required this.setId,
    this.initialSet,
    this.apiService,
  });

  @override
  State<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends State<SetDetailScreen> {
  late final ApiService _api;
  late Future<LegoSet> _futureSet;
  late Future<List<LegoSet>> _futureRelated;

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? ApiService();
    _loadData();
  }

  // Muat detail set dan daftar set terkait di tema yang sama.
  void _loadData() {
    _futureSet = _api.fetchSetById(widget.setId);
    _futureRelated = _fetchRelated();
  }

  Future<List<LegoSet>> _fetchRelated() async {
    final current = await _futureSet;
    final list = await _api.fetchSets(themeId: current.themeId);
    return list.where((s) => s.id != widget.setId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistStore.instance;

    return FutureBuilder<LegoSet>(
      future: _futureSet,
      builder: (context, snapshot) {
        final legoSet = snapshot.data ?? widget.initialSet;
        final title = legoSet?.name.orPlaceholder('Set Detail') ?? 'Set Detail';

        return Title(
          color: LegoCatalogApp.legoYellow,
          title: '$title | LEGO COLLECTION',
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (legoSet != null)
                  ListenableBuilder(
                    listenable: wishlist,
                    builder: (context, _) {
                      final saved = wishlist.contains(legoSet.id);
                      return IconButton(
                        tooltip: saved
                            ? 'Remove from Wishlist'
                            : 'Save to Wishlist',
                        icon: Icon(
                          saved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: saved
                              ? LegoCatalogApp.legoRed
                              : LegoCatalogApp.textPrimary,
                        ),
                        onPressed: () =>
                            toggleWishlistWithFeedback(context, legoSet),
                      );
                    },
                  ),
              ],
            ),
            body: _buildBody(context, snapshot),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<LegoSet> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LegoLoadingState();
    }
    if (snapshot.hasError) {
      return LegoErrorState(
        message: '${snapshot.error}',
        onRetry: () => setState(_loadData),
      );
    }

    final legoSet = snapshot.data!;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 36;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final photoCard = _PhotoShowcaseCard(imageUrl: legoSet.imageUrl);
        final detailsColumn = _DetailsColumn(legoSet: legoSet);

        return Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 28 : 20,
                        isWide ? 28 : 20,
                        isWide ? 28 : 20,
                        0,
                      ),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 6, child: detailsColumn),
                                const SizedBox(width: 32),
                                Expanded(flex: 5, child: photoCard),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                photoCard,
                                const SizedBox(height: 22),
                                detailsColumn,
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                _RelatedSetsCarousel(
                  themeName: legoSet.theme,
                  futureRelated: _futureRelated,
                  apiService: _api,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhotoShowcaseCard extends StatelessWidget {
  final String imageUrl;

  const _PhotoShowcaseCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: LegoCatalogApp.borderLight),
      ),
      padding: const EdgeInsets.all(24),
      child: AspectRatio(
        aspectRatio: 1,
        child: LegoNetworkImage(
          url: imageUrl,
          fit: BoxFit.contain,
          cacheWidth: 600,
          cacheHeight: 600,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class _DetailsColumn extends StatelessWidget {
  final LegoSet legoSet;

  const _DetailsColumn({required this.legoSet});

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistStore.instance;
    final swatch = CurrencyFormatter.themeSwatch(legoSet.themeId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            LegoBadgePill(
              text: '#${legoSet.setNumber.orPlaceholder()}',
              backgroundColor: LegoCatalogApp.legoRed,
              textColor: Colors.white,
            ),
            LegoBadgePill(
              text: 'AGE ${legoSet.ageRating.orPlaceholder()}',
              backgroundColor: LegoCatalogApp.legoYellow,
              textColor: LegoCatalogApp.textPrimary,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, color: swatch),
                const SizedBox(width: 6),
                Text(
                  legoSet.theme.orPlaceholder().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: LegoCatalogApp.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          legoSet.name.orPlaceholder().toUpperCase(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            height: 1.2,
            color: LegoCatalogApp.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          CurrencyFormatter.toRupiah(legoSet.priceIdr),
          style: const TextStyle(
            fontSize: 20,
            color: LegoCatalogApp.legoRed,
            fontWeight: FontWeight.w800,
            fontFeatures: LegoCatalogApp.tabularNums,
          ),
        ),
        const SizedBox(height: 20),
        ListenableBuilder(
          listenable: wishlist,
          builder: (context, _) {
            final saved = wishlist.contains(legoSet.id);
            return OutlinedButton.icon(
              onPressed: () => toggleWishlistWithFeedback(context, legoSet),
              style: OutlinedButton.styleFrom(
                backgroundColor: saved
                    ? LegoCatalogApp.textPrimary
                    : Colors.white,
                foregroundColor: saved
                    ? Colors.white
                    : LegoCatalogApp.textPrimary,
                side: const BorderSide(color: LegoCatalogApp.textPrimary),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 18,
                ),
              ),
              icon: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 18,
                color: saved
                    ? LegoCatalogApp.legoYellow
                    : LegoCatalogApp.textPrimary,
              ),
              label: Text(saved ? 'SAVED IN WISHLIST' : 'SAVE TO WISHLIST'),
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: LegoCatalogApp.borderLight),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SpecCell(
                      label: 'TOTAL PIECES',
                      value:
                          '${CurrencyFormatter.thousands(legoSet.pieces)} pcs',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 64,
                    color: LegoCatalogApp.borderLight,
                  ),
                  Expanded(
                    child: _SpecCell(
                      label: 'AGE RATING',
                      value: legoSet.ageRating.orPlaceholder(),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SpecCell(
                      label: 'RELEASE YEAR',
                      value: '${legoSet.releaseYear}',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 64,
                    color: LegoCatalogApp.borderLight,
                  ),
                  Expanded(
                    child: _SpecCell(
                      label: 'DIMENSIONS',
                      value: legoSet.dimensions.orPlaceholder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'PRODUCT DESCRIPTION',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: LegoCatalogApp.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          legoSet.description.orPlaceholder(),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF333333),
            height: 1.65,
          ),
        ),
      ],
    );
  }
}

class _SpecCell extends StatelessWidget {
  final String label;
  final String value;

  const _SpecCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: LegoCatalogApp.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: LegoCatalogApp.textPrimary,
              fontFeatures: LegoCatalogApp.tabularNums,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedSetsCarousel extends StatelessWidget {
  final String themeName;
  final Future<List<LegoSet>> futureRelated;
  final ApiService? apiService;

  const _RelatedSetsCarousel({
    required this.themeName,
    required this.futureRelated,
    this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RELATED SETS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: LegoCatalogApp.legoRed,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'MORE FROM ${themeName.orPlaceholder().toUpperCase()}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: LegoCatalogApp.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FutureBuilder<List<LegoSet>>(
          future: futureRelated,
          builder: (context, relSnap) {
            if (relSnap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: LegoLoadingState(),
              );
            }
            final related = relSnap.data ?? [];
            if (related.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No other sets available in this theme.',
                  style: TextStyle(color: LegoCatalogApp.textSecondary),
                ),
              );
            }
            return SizedBox(
              height: 386,
              child: HorizontalEdgeFade(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: related.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = related[index];
                    return LegoEditorialCard(
                      legoSet: item,
                      width: 236,
                      expandImage: true,
                      onTap: () =>
                          openSetDetail(context, item, apiService: apiService),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
