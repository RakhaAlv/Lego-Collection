import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../models/lego_theme.dart';
import '../services/api_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lego_set_card.dart';

enum _SetSortOption {
  defaultOrder('SORT: DEFAULT'),
  priceAsc('PRICE: LOW TO HIGH'),
  priceDesc('PRICE: HIGH TO LOW'),
  piecesDesc('MOST PIECES'),
  yearDesc('NEWEST');

  final String label;
  const _SetSortOption(this.label);
}

class SetsListScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final ValueListenable<int?>? themeFilterSignal;
  final ApiService? apiService;

  const SetsListScreen({
    super.key,
    this.scrollController,
    this.themeFilterSignal,
    this.apiService,
  });

  @override
  State<SetsListScreen> createState() => _SetsListScreenState();
}

class _SetsListScreenState extends State<SetsListScreen> {
  late final ApiService _api;
  late final ScrollController _ownedVerticalController;
  final TextEditingController _searchController = TextEditingController();
  final Map<int?, GlobalKey> _chipKeys = {};

  late Future<List<LegoSet>> _futureSets;
  List<LegoTheme> _themes = [];
  int? _selectedThemeId;
  String _query = '';
  _SetSortOption _sortOption = _SetSortOption.defaultOrder;

  ScrollController get _gridController =>
      widget.scrollController ?? _ownedVerticalController;

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? ApiService();
    _ownedVerticalController = ScrollController();
    _futureSets = _api.fetchSets();
    _loadThemes();
    widget.themeFilterSignal?.addListener(_handleExternalThemeSignal);
  }

  @override
  void didUpdateWidget(covariant SetsListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeFilterSignal != widget.themeFilterSignal) {
      oldWidget.themeFilterSignal?.removeListener(_handleExternalThemeSignal);
      widget.themeFilterSignal?.addListener(_handleExternalThemeSignal);
    }
  }

  @override
  void dispose() {
    widget.themeFilterSignal?.removeListener(_handleExternalThemeSignal);
    _ownedVerticalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Sinkronkan tab filter ketika pengguna mengetuk kategori tema di Home.
  void _handleExternalThemeSignal() {
    final val = widget.themeFilterSignal?.value;
    if (val == null) return;
    _applyThemeFilter(val < 0 ? null : val, scrollChipIntoView: true);
  }

  Future<void> _loadThemes() async {
    try {
      final themes = await _api.fetchThemes();
      if (mounted) setState(() => _themes = themes);
    } catch (_) {}
  }

  Future<void> _reload() async {
    HapticFeedback.selectionClick();
    final nextFuture = _api.fetchSets(themeId: _selectedThemeId);
    if (!mounted) return;
    setState(() {
      _futureSets = nextFuture;
    });
    if (_themes.isEmpty) {
      await _loadThemes();
    }
    await nextFuture;
  }

  // Ambil ulang data set dari API sesuai tema terpilih lalu geser chip filter agar terlihat.
  void _applyThemeFilter(int? id, {bool scrollChipIntoView = true}) {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();
    setState(() {
      _selectedThemeId = id;
      _futureSets = _api.fetchSets(themeId: id);
    });
    if (_gridController.hasClients && _gridController.offset > 0) {
      _gridController.jumpTo(0);
    }
    if (scrollChipIntoView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _chipKeys[id]?.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 240),
            alignment: 0.35,
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // Filter hasil berdasarkan pencarian dan urutkan di sisi client.
  List<LegoSet> _filterAndSort(List<LegoSet> raw) {
    final filtered = raw
        .where(
          (s) =>
              _query.isEmpty ||
              s.name.toLowerCase().contains(_query) ||
              s.setNumber.contains(_query),
        )
        .toList();

    switch (_sortOption) {
      case _SetSortOption.defaultOrder:
        break;
      case _SetSortOption.priceAsc:
        filtered.sort((a, b) => a.priceIdr.compareTo(b.priceIdr));
      case _SetSortOption.priceDesc:
        filtered.sort((a, b) => b.priceIdr.compareTo(a.priceIdr));
      case _SetSortOption.piecesDesc:
        filtered.sort((a, b) => b.pieces.compareTo(a.pieces));
      case _SetSortOption.yearDesc:
        filtered.sort((a, b) => b.releaseYear.compareTo(a.releaseYear));
    }
    return filtered;
  }

  GlobalKey _keyForChip(int? id) =>
      _chipKeys.putIfAbsent(id, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const LegoAppBarTitle(title: 'CATALOG')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              onChanged: (v) {
                setState(() => _query = v.trim().toLowerCase());
                if (_gridController.hasClients && _gridController.offset > 0) {
                  _gridController.jumpTo(0);
                }
              },
              style: const TextStyle(
                fontSize: 13.5,
                color: LegoCatalogApp.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by set name or number (e.g. 76269, Castle, Falcon)...',
                hintStyle: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_sharp,
                  size: 19,
                  color: LegoCatalogApp.textPrimary,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_sharp, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),

          Container(
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                horizontal: BorderSide(color: LegoCatalogApp.borderLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: HorizontalEdgeFade(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _EditorialFilterTab(
                          key: _keyForChip(null),
                          label: 'ALL',
                          selected: _selectedThemeId == null,
                          onTap: () => _applyThemeFilter(null),
                        ),
                        ..._themes.map(
                          (t) => _EditorialFilterTab(
                            key: _keyForChip(t.id),
                            label: CurrencyFormatter.shortTheme(t.themeName),
                            selected: _selectedThemeId == t.id,
                            onTap: () => _applyThemeFilter(t.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 20),
                  child: PopupMenuButton<_SetSortOption>(
                    tooltip: 'Sort sets',
                    initialValue: _sortOption,
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    position: PopupMenuPosition.under,
                    onOpened: () =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onSelected: (option) {
                      HapticFeedback.selectionClick();
                      setState(() => _sortOption = option);
                      if (_gridController.hasClients &&
                          _gridController.offset > 0) {
                        _gridController.jumpTo(0);
                      }
                    },
                    itemBuilder: (context) => _SetSortOption.values
                        .map(
                          (opt) => PopupMenuItem(
                            value: opt,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  color: opt == _sortOption
                                      ? LegoCatalogApp.legoRed
                                      : Colors.transparent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  opt.label,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: opt == _sortOption
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    letterSpacing: 0.9,
                                    color: LegoCatalogApp.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: LegoCatalogApp.borderLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _sortOption.label,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: LegoCatalogApp.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_down_sharp,
                            size: 16,
                            color: LegoCatalogApp.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<LegoSet>>(
              future: _futureSets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LegoLoadingState();
                }
                if (snapshot.hasError) {
                  return LegoErrorState(
                    message: '${snapshot.error}',
                    onRetry: _reload,
                  );
                }

                final sets = _filterAndSort(snapshot.data ?? []);
                if (sets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_sharp,
                            size: 44,
                            color: LegoCatalogApp.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'NO MATCHING SETS FOUND',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: LegoCatalogApp.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _selectedThemeId = null;
                                _sortOption = _SetSortOption.defaultOrder;
                                _futureSets = _api.fetchSets();
                              });
                            },
                            child: const Text('RESET FILTERS'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 24;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final crossAxisCount = w >= 1040 ? 4 : (w >= 680 ? 3 : 2);
                    const horizontalPad = 40.0;
                    const crossSpacing = 16.0;
                    final cellWidth =
                        (w -
                            horizontalPad -
                            crossSpacing * (crossAxisCount - 1)) /
                        crossAxisCount;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Text(
                            '${sets.length} ${sets.length == 1 ? 'SET' : 'SETS'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: LegoCatalogApp.textSecondary,
                              fontFeatures: LegoCatalogApp.tabularNums,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            color: LegoCatalogApp.legoRed,
                            onRefresh: _reload,
                            child: Scrollbar(
                              controller: _gridController,
                              child: GridView.builder(
                                controller: _gridController,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: EdgeInsets.fromLTRB(
                                  20,
                                  4,
                                  20,
                                  bottomPad,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: crossSpacing,
                                      mainAxisSpacing: 22,
                                      mainAxisExtent: cellWidth + 136,
                                    ),
                                itemCount: sets.length,
                                itemBuilder: (context, index) {
                                  final setItem = sets[index];
                                  return LegoEditorialCard(
                                    legoSet: setItem,
                                    expandImage: true,
                                    onTap: () => openSetDetail(
                                      context,
                                      setItem,
                                      apiService: _api,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.scrollController != null) {
      content = PrimaryScrollController(
        controller: widget.scrollController!,
        child: content,
      );
    }

    return Title(
      color: LegoCatalogApp.legoYellow,
      title: 'Catalog | LEGO COLLECTION',
      child: content,
    );
  }
}

class _EditorialFilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _EditorialFilterTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? LegoCatalogApp.legoRed : Colors.transparent,
              width: 2.2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 1.2,
            color: selected
                ? LegoCatalogApp.textPrimary
                : LegoCatalogApp.textSecondary,
          ),
        ),
      ),
    );
  }
}
