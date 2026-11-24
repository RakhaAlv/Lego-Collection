import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../models/lego_theme.dart';
import '../services/api_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lego_set_card.dart';

class HomeScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final ApiService? apiService;
  final ValueChanged<int?>? onOpenCatalog;
  final VoidCallback? onOpenCompare;

  const HomeScreen({
    super.key,
    this.scrollController,
    this.apiService,
    this.onOpenCatalog,
    this.onOpenCompare,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiService _api;
  List<LegoSet> _sets = [];
  List<LegoTheme> _themes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? ApiService();
    _loadHomeData();
  }

  // Muat daftar set dan tema paralel dengan Future.wait agar loading lebih cepat.
  Future<void> _loadHomeData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([_api.fetchSets(), _api.fetchThemes()]);
      if (!mounted) return;
      setState(() {
        _sets = results[0] as List<LegoSet>;
        _themes = results[1] as List<LegoTheme>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  List<LegoSet> _buildHeroSlides() {
    if (_sets.isEmpty) return const [];
    const priorityNumbers = ['76269', '43222', '76444', '71837', '75375'];
    final slides = <LegoSet>[
      for (final num in priorityNumbers)
        ..._sets.where((s) => s.setNumber == num).take(1),
    ];
    return slides.length >= 2 ? slides : _sets.take(4).toList();
  }

  void _triggerCatalog([int? themeId]) {
    HapticFeedback.selectionClick();
    widget.onOpenCatalog?.call(themeId);
  }

  Widget _buildHorizontalProductRow(List<LegoSet> items) {
    return SizedBox(
      height: 392,
      child: HorizontalEdgeFade(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            return LegoEditorialCard(
              legoSet: item,
              width: 248,
              expandImage: true,
              onTap: () => openSetDetail(context, item, apiService: _api),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.scrollController;

    Widget content = Scaffold(
      appBar: AppBar(title: const LegoAppBarTitle(title: 'LEGO COLLECTION')),
      body: _buildBody(context),
    );

    if (controller != null) {
      content = PrimaryScrollController(controller: controller, child: content);
    }

    return Title(
      color: LegoCatalogApp.legoYellow,
      title: 'Home | LEGO COLLECTION',
      child: content,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const LegoLoadingState();
    if (_error != null) {
      return LegoErrorState(message: _error!, onRetry: _loadHomeData);
    }

    final heroSlides = _buildHeroSlides();

    final collectorSets =
        _sets.where((s) => s.pieces >= 1000 || s.ageRating == '18+').toList()
          ..sort((a, b) => b.pieces.compareTo(a.pieces));

    final newestSets = List<LegoSet>.from(_sets)
      ..sort((a, b) {
        final byYear = b.releaseYear.compareTo(a.releaseYear);
        return byYear != 0 ? byYear : b.pieces.compareTo(a.pieces);
      });

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return RefreshIndicator(
      color: LegoCatalogApp.legoRed,
      onRefresh: _loadHomeData,
      child: Scrollbar(
        controller: widget.scrollController,
        child: ListView(
          controller: widget.scrollController,
          padding: EdgeInsets.only(bottom: bottomInset),
          children: [
            Container(
              width: double.infinity,
              color: LegoCatalogApp.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    color: LegoCatalogApp.legoYellow,
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'LEGO COLLECTION  |    LETS BUILD TOGETHER',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (heroSlides.isNotEmpty)
              _HeroBannerCarousel(
                slides: heroSlides,
                onExploreCatalog: () => _triggerCatalog(),
                onOpenDetail: (item) =>
                    openSetDetail(context, item, apiService: _api),
              ),

            if (_themes.isNotEmpty) ...[
              const SizedBox(height: 44),
              _EditorialSectionHeader(
                eyebrow: '6 CORE COLLECTIONS',
                title: 'SHOP BY THEME',
                actionLabel: 'ALL SETS',
                onAction: widget.onOpenCatalog == null
                    ? null
                    : () => _triggerCatalog(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 238,
                child: HorizontalEdgeFade(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _themes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final theme = _themes[index];
                      return _ThemeCollectionTile(
                        theme: theme,
                        onTap: () => _triggerCatalog(theme.id),
                      );
                    },
                  ),
                ),
              ),
            ],

            if (collectorSets.isNotEmpty) ...[
              const SizedBox(height: 48),
              _EditorialSectionHeader(
                eyebrow: 'FEATURED SETS',
                title: 'COLLECTOR EDITION',
                actionLabel: 'VIEW ALL',
                onAction: widget.onOpenCatalog == null
                    ? null
                    : () => _triggerCatalog(),
              ),
              const SizedBox(height: 20),
              _buildHorizontalProductRow(collectorSets),
            ],

            const SizedBox(height: 52),
            _CompareEditorialBanner(
              onOpenCompare: () {
                HapticFeedback.selectionClick();
                widget.onOpenCompare?.call();
              },
            ),

            if (newestSets.isNotEmpty) ...[
              const SizedBox(height: 48),
              _EditorialSectionHeader(
                eyebrow: 'LATEST RELEASES',
                title: 'NEW ARRIVALS',
                actionLabel: 'VIEW ALL',
                onAction: widget.onOpenCatalog == null
                    ? null
                    : () => _triggerCatalog(),
              ),
              const SizedBox(height: 20),
              _buildHorizontalProductRow(newestSets.take(10).toList()),
            ],

            const SizedBox(height: 56),
            const _EditorialFooter(),
          ],
        ),
      ),
    );
  }
}

// Hero banner otomatis bergeser setiap 4 detik dan bisa digeser manual.
class _HeroBannerCarousel extends StatefulWidget {
  final List<LegoSet> slides;
  final VoidCallback onExploreCatalog;
  final ValueChanged<LegoSet> onOpenDetail;

  const _HeroBannerCarousel({
    required this.slides,
    required this.onExploreCatalog,
    required this.onOpenDetail,
  });

  @override
  State<_HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<_HeroBannerCarousel> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(covariant _HeroBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _currentSlide = 0;
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.slides.length <= 1) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentSlide + 1) % widget.slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _goToSlide(int index) {
    if (!_pageController.hasClients || widget.slides.isEmpty) return;
    HapticFeedback.selectionClick();
    final target = (index + widget.slides.length) % widget.slides.length;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final double bannerHeight = isWide ? 430 : 570;

        return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: LegoCatalogApp.borderLight),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: bannerHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentSlide = index);
                    _startAutoSlide();
                  },
                  itemBuilder: (context, index) {
                    final item = widget.slides[index];
                    return _HeroSlideItem(
                      heroSet: item,
                      isWide: isWide,
                      onExploreCatalog: widget.onExploreCatalog,
                      onOpenDetail: () => widget.onOpenDetail(item),
                    );
                  },
                ),
              ),
              if (widget.slides.length > 1)
                Container(
                  color: LegoCatalogApp.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(widget.slides.length, (i) {
                          final active = i == _currentSlide;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _goToSlide(i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: active ? 28 : 10,
                                height: 3,
                                color: active
                                    ? LegoCatalogApp.legoYellow
                                    : Colors.white30,
                              ),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      Text(
                        '0${_currentSlide + 1} / 0${widget.slides.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          fontFeatures: LegoCatalogApp.tabularNums,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _SlideNavButton(
                        icon: Icons.chevron_left_sharp,
                        onTap: () => _goToSlide(_currentSlide - 1),
                      ),
                      const SizedBox(width: 6),
                      _SlideNavButton(
                        icon: Icons.chevron_right_sharp,
                        onTap: () => _goToSlide(_currentSlide + 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SlideNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SlideNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}

class _HeroSlideItem extends StatelessWidget {
  final LegoSet heroSet;
  final bool isWide;
  final VoidCallback onExploreCatalog;
  final VoidCallback onOpenDetail;

  const _HeroSlideItem({
    required this.heroSet,
    required this.isWide,
    required this.onExploreCatalog,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final copyBlock = Container(
      color: LegoCatalogApp.textPrimary,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 48 : 24,
        vertical: isWide ? 36 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${heroSet.theme.orPlaceholder().toUpperCase()}  ·  #${heroSet.setNumber.orPlaceholder()}  ·  AGE ${heroSet.ageRating.orPlaceholder()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LegoCatalogApp.legoYellow,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            heroSet.name.orPlaceholder().toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 32 : 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            heroSet.description.orPlaceholder(),
            maxLines: isWide ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD0D0D0),
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${CurrencyFormatter.toRupiah(heroSet.priceIdr)}   ·   ${CurrencyFormatter.thousands(heroSet.pieces)} pcs',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontFeatures: LegoCatalogApp.tabularNums,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: onExploreCatalog,
                style: FilledButton.styleFrom(
                  backgroundColor: LegoCatalogApp.legoYellow,
                  foregroundColor: LegoCatalogApp.textPrimary,
                ),
                child: const Text('EXPLORE CATALOG'),
              ),
              OutlinedButton(
                onPressed: onOpenDetail,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                child: const Text('VIEW SET'),
              ),
            ],
          ),
        ],
      ),
    );

    final studioBlock = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpenDetail,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: LegoNetworkImage(
          url: heroSet.imageUrl,
          fit: BoxFit.contain,
          cacheWidth: 640,
          cacheHeight: 640,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 6, child: copyBlock),
          Container(width: 4, color: LegoCatalogApp.legoRed),
          Expanded(flex: 5, child: studioBlock),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 5, child: studioBlock),
        Container(height: 3, color: LegoCatalogApp.legoRed),
        Expanded(flex: 6, child: copyBlock),
      ],
    );
  }
}

class _EditorialSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EditorialSectionHeader({
    required this.eyebrow,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: LegoCatalogApp.legoRed,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: LegoCatalogApp.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 2),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 3),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: LegoCatalogApp.textPrimary,
                        width: 1.2,
                      ),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: LegoCatalogApp.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeCollectionTile extends StatelessWidget {
  final LegoTheme theme;
  final VoidCallback onTap;

  const _ThemeCollectionTile({required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final shortName = CurrencyFormatter.shortTheme(theme.themeName);
    final swatch = CurrencyFormatter.themeSwatch(theme.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 190,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: const BorderSide(color: LegoCatalogApp.borderLight),
                    left: const BorderSide(color: LegoCatalogApp.borderLight),
                    right: const BorderSide(color: LegoCatalogApp.borderLight),
                    bottom: BorderSide(color: swatch, width: 3),
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: LegoNetworkImage(
                  url: theme.imageUrl,
                  fit: BoxFit.contain,
                  cacheWidth: 320,
                  cacheHeight: 320,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              shortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: LegoCatalogApp.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'SINCE ${theme.establishedYear}  ·  5 SETS',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.7,
                color: LegoCatalogApp.textSecondary,
                fontFeatures: LegoCatalogApp.tabularNums,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareEditorialBanner extends StatelessWidget {
  final VoidCallback onOpenCompare;

  const _CompareEditorialBanner({required this.onOpenCompare});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: LegoCatalogApp.backgroundLight,
        border: Border.symmetric(
          horizontal: BorderSide(color: LegoCatalogApp.borderLight),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 620;
              const textPart = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SET COMPARISON',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: LegoCatalogApp.legoRed,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'COMPARE TWO SETS SIDE BY SIDE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: LegoCatalogApp.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Evaluate piece counts, pricing, and price-per-piece ratio '
                    'side by side before picking your next build.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: LegoCatalogApp.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              );

              final cta = FilledButton(
                onPressed: onOpenCompare,
                child: const Text('OPEN COMPARE'),
              );

              if (isWide) {
                return Row(
                  children: [
                    const Expanded(child: textPart),
                    const SizedBox(width: 28),
                    cta,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [textPart, const SizedBox(height: 18), cta],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Footer penutup di bagian paling bawah Homepage.
class _EditorialFooter extends StatelessWidget {
  const _EditorialFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: LegoCatalogApp.textPrimary,
        border: Border(
          top: BorderSide(color: LegoCatalogApp.legoYellow, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      child: const Column(
        children: [
          Text(
            'LEGO COLLECTION',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'MARVEL  ·  DISNEY  ·  HARRY POTTER  ·  NINJAGO  ·  LEGO CITY  ·  STAR WARS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA8A8A8),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '© 2026 Rakha Aljiva Prabaswara  ·  LEGO® is a trademark of the LEGO Group.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF888888), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
