import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../models/lego_theme.dart';
import '../services/api_service.dart';
import '../widgets/lego_set_card.dart';
import 'set_detail_screen.dart';

enum _SetSortOption {
  defaultOrder('Default'),
  priceAsc('Harga Terendah'),
  priceDesc('Harga Tertinggi'),
  piecesDesc('Keping Terbanyak'),
  yearDesc('Terbaru');

  final String label;
  const _SetSortOption(this.label);
}

/// Tab 1: daftar Set LEGO dari endpoint GET /api/sets (filter opsional ?theme_id= & sort).
class SetsListScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const SetsListScreen({super.key, this.scrollController});

  @override
  State<SetsListScreen> createState() => _SetsListScreenState();
}

class _SetsListScreenState extends State<SetsListScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<LegoSet>> _futureSets;
  List<LegoTheme> _themes = [];
  int? _selectedThemeId;
  String _query = '';
  _SetSortOption _sortOption = _SetSortOption.defaultOrder;

  @override
  void initState() {
    super.initState();
    _futureSets = _api.fetchSets();
    _loadThemes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadThemes() async {
    try {
      final themes = await _api.fetchThemes();
      if (mounted) setState(() => _themes = themes);
    } catch (_) {
      // Filter tema bersifat opsional; abaikan bila gagal.
    }
  }

  Future<void> _refresh() async {
    final future = _api.fetchSets(themeId: _selectedThemeId);
    setState(() => _futureSets = future);
    if (_themes.isEmpty) _loadThemes();
    await future.catchError((_) => <LegoSet>[]);
  }

  void _selectTheme(int? id) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedThemeId = id;
      _futureSets = _api.fetchSets(themeId: id);
    });
  }

  List<LegoSet> _filterAndSort(List<LegoSet> raw) {
    final filtered = raw
        .where((s) =>
            _query.isEmpty ||
            s.name.toLowerCase().contains(_query) ||
            s.setNumber.contains(_query))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LegoAppBarTitle(title: 'Katalog LEGO'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: LegoCatalogApp.borderLight)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau nomor set...',
                      hintStyle: const TextStyle(color: Color(0xFF777777), fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: LegoCatalogApp.textSecondary),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                      filled: true,
                      fillColor: LegoCatalogApp.backgroundLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: LegoCatalogApp.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: LegoCatalogApp.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: LegoCatalogApp.legoRed, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Row(
                    children: [
                      PopupMenuButton<_SetSortOption>(
                        tooltip: 'Urutkan Set',
                        initialValue: _sortOption,
                        onSelected: (option) {
                          HapticFeedback.selectionClick();
                          setState(() => _sortOption = option);
                        },
                        itemBuilder: (context) => _SetSortOption.values
                            .map(
                              (opt) => PopupMenuItem(
                                value: opt,
                                child: Row(
                                  children: [
                                    Icon(
                                      opt == _sortOption
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      size: 18,
                                      color: opt == _sortOption
                                          ? LegoCatalogApp.legoRed
                                          : const Color(0xFF999999),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(opt.label),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: _sortOption == _SetSortOption.defaultOrder
                                ? Colors.white
                                : LegoCatalogApp.legoYellowTint,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _sortOption == _SetSortOption.defaultOrder
                                  ? LegoCatalogApp.borderLight
                                  : LegoCatalogApp.legoYellow,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sort_rounded,
                                size: 17,
                                color: LegoCatalogApp.textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _sortOption == _SetSortOption.defaultOrder
                                    ? 'Urutkan'
                                    : _sortOption.label,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: LegoCatalogApp.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 18,
                                color: LegoCatalogApp.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 22, color: LegoCatalogApp.borderLight),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            children: [
                              _ThemeChip(
                                label: 'Semua',
                                selected: _selectedThemeId == null,
                                onSelected: () => _selectTheme(null),
                              ),
                              ..._themes.map(
                                (t) => _ThemeChip(
                                  label: _shortThemeLabel(t.themeName),
                                  selected: _selectedThemeId == t.id,
                                  onSelected: () => _selectTheme(t.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                  return const Center(
                    child: CircularProgressIndicator(color: LegoCatalogApp.legoRed),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorView(message: '${snapshot.error}', onRetry: _refresh);
                }

                final sets = _filterAndSort(snapshot.data ?? []);

                return RefreshIndicator(
                  color: LegoCatalogApp.legoRed,
                  onRefresh: _refresh,
                  child: sets.isEmpty
                      ? ListView(
                          controller: widget.scrollController,
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          children: const [
                            SizedBox(height: 100),
                            Icon(Icons.search_off_rounded, size: 64, color: Color(0xFF999999)),
                            SizedBox(height: 12),
                            Center(
                              child: Text(
                                'Set LEGO tidak ditemukan',
                                style: TextStyle(
                                  color: LegoCatalogApp.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                              child: _ResultSummaryBar(
                                count: sets.length,
                                sortOption: _sortOption,
                                onResetSort: _sortOption == _SetSortOption.defaultOrder
                                    ? null
                                    : () => setState(() => _sortOption = _SetSortOption.defaultOrder),
                              ),
                            ),
                            Expanded(
                              child: Scrollbar(
                                controller: widget.scrollController,
                                child: ListView.builder(
                                  controller: widget.scrollController,
                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                                  itemExtent: 170,
                                  itemCount: sets.length,
                                  itemBuilder: (context, index) {
                                    final setItem = sets[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: LegoSetCard(
                                        legoSet: setItem,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SetDetailScreen(
                                              setId: setItem.id,
                                              initialSet: setItem,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _shortThemeLabel(String name) =>
      name == 'LEGO City' ? name : name.replaceFirst('LEGO ', '');
}

class _ResultSummaryBar extends StatelessWidget {
  final int count;
  final _SetSortOption sortOption;
  final VoidCallback? onResetSort;

  const _ResultSummaryBar({
    required this.count,
    required this.sortOption,
    this.onResetSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            'Menampilkan $count set LEGO',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: LegoCatalogApp.textSecondary,
            ),
          ),
          const Spacer(),
          if (sortOption != _SetSortOption.defaultOrder)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onResetSort,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LegoCatalogApp.legoYellowTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sortOption.label,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: LegoCatalogApp.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.close, size: 14, color: LegoCatalogApp.textPrimary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onSelected(),
        selectedColor: LegoCatalogApp.legoRed,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? LegoCatalogApp.legoRed : LegoCatalogApp.borderLight,
        ),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : LegoCatalogApp.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: LegoCatalogApp.legoRed),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: LegoCatalogApp.textPrimary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
