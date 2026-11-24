import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../services/api_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lego_set_card.dart';

class CompareSetsScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final ApiService? apiService;

  const CompareSetsScreen({super.key, this.scrollController, this.apiService});

  @override
  State<CompareSetsScreen> createState() => _CompareSetsScreenState();
}

class _CompareSetsScreenState extends State<CompareSetsScreen> {
  late final ApiService _api;
  List<LegoSet> _sets = [];
  int? _setAId;
  int? _setBId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? ApiService();
    _loadSets();
  }

  // Muat daftar set dari API lalu set nilai default Set A dan Set B.
  Future<void> _loadSets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sets = await _api.fetchSets();
      if (!mounted) return;
      setState(() {
        _sets = sets;
        if (sets.isNotEmpty) {
          _setAId ??= sets.first.id;
          _setBId ??= sets.length > 1 ? sets[1].id : sets.first.id;
        }
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

  LegoSet? _findSet(int? id) {
    if (id == null || _sets.isEmpty) return null;
    return _sets.firstWhere((s) => s.id == id, orElse: () => _sets.first);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.scrollController;
    Widget content = Scaffold(
      appBar: AppBar(title: const LegoAppBarTitle(title: 'COMPARE SETS')),
      body: _buildBody(context),
    );
    if (controller != null) {
      content = PrimaryScrollController(controller: controller, child: content);
    }
    return Title(
      color: LegoCatalogApp.legoYellow,
      title: 'Compare | LEGO COLLECTION',
      child: content,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const LegoLoadingState();
    if (_error != null) {
      return LegoErrorState(message: _error!, onRetry: _loadSets);
    }

    final setA = _findSet(_setAId);
    final setB = _findSet(_setBId);
    if (setA == null || setB == null) {
      return const Center(child: Text('No sets available to compare.'));
    }

    final perPieceA = setA.pricePerPiece;
    final perPieceB = setB.pricePerPiece;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 28;

    return RefreshIndicator(
      color: LegoCatalogApp.legoRed,
      onRefresh: _loadSets,
      child: Scrollbar(
        controller: widget.scrollController,
        child: ListView(
          controller: widget.scrollController,
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SELECT TWO SETS TO COMPARE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: LegoCatalogApp.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _SetSelectorDropdown(
                                    key: const ValueKey('compare-dropdown-a'),
                                    label: 'SET A',
                                    value: setA.id,
                                    sets: _sets,
                                    onChanged: (id) {
                                      if (id == null) return;
                                      HapticFeedback.selectionClick();
                                      setState(() => _setAId = id);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SetSelectorDropdown(
                                    key: const ValueKey('compare-dropdown-b'),
                                    label: 'SET B',
                                    value: setB.id,
                                    sets: _sets,
                                    onChanged: (id) {
                                      if (id == null) return;
                                      HapticFeedback.selectionClick();
                                      setState(() => _setBId = id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _CompareSetHeader(
                                slotLabel: 'SET A',
                                legoSet: setA,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _CompareSetHeader(
                                slotLabel: 'SET B',
                                legoSet: setB,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Column(
                          children: [
                            _CompareMetricRow(
                              label: 'Set Number',
                              valueA: '#${setA.setNumber.orPlaceholder()}',
                              valueB: '#${setB.setNumber.orPlaceholder()}',
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Theme',
                              valueA: setA.theme.orPlaceholder(),
                              valueB: setB.theme.orPlaceholder(),
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Price',
                              valueA: CurrencyFormatter.toRupiah(setA.priceIdr),
                              valueB: CurrencyFormatter.toRupiah(setB.priceIdr),
                              highlightValue: true,
                              badgeA: setA.priceIdr < setB.priceIdr
                                  ? 'BEST VALUE'
                                  : null,
                              badgeB: setB.priceIdr < setA.priceIdr
                                  ? 'BEST VALUE'
                                  : null,
                              greenBadge: true,
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Pieces',
                              valueA:
                                  '${CurrencyFormatter.thousands(setA.pieces)} pcs',
                              valueB:
                                  '${CurrencyFormatter.thousands(setB.pieces)} pcs',
                              badgeA: setA.pieces > setB.pieces
                                  ? 'MORE PIECES'
                                  : null,
                              badgeB: setB.pieces > setA.pieces
                                  ? 'MORE PIECES'
                                  : null,
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Price / Piece',
                              valueA:
                                  '${CurrencyFormatter.toRupiah(perPieceA)} / pcs',
                              valueB:
                                  '${CurrencyFormatter.toRupiah(perPieceB)} / pcs',
                              badgeA:
                                  perPieceA > 0 &&
                                      perPieceB > 0 &&
                                      perPieceA < perPieceB
                                  ? 'BEST VALUE'
                                  : null,
                              badgeB:
                                  perPieceA > 0 &&
                                      perPieceB > 0 &&
                                      perPieceB < perPieceA
                                  ? 'BEST VALUE'
                                  : null,
                              greenBadge: true,
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Age Rating',
                              valueA: setA.ageRating.orPlaceholder(),
                              valueB: setB.ageRating.orPlaceholder(),
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Release Year',
                              valueA: '${setA.releaseYear}',
                              valueB: '${setB.releaseYear}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetSelectorDropdown extends StatelessWidget {
  final String label;
  final int value;
  final List<LegoSet> sets;
  final ValueChanged<int?> onChanged;

  const _SetSelectorDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.sets,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: LegoCatalogApp.textPrimary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
      ),
      items: sets
          .map(
            (s) => DropdownMenuItem<int>(
              value: s.id,
              child: Text(
                '#${s.setNumber} · ${s.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: LegoCatalogApp.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CompareSetHeader extends StatelessWidget {
  final String slotLabel;
  final LegoSet legoSet;

  const _CompareSetHeader({required this.slotLabel, required this.legoSet});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: LegoCatalogApp.borderLight),
            ),
            padding: const EdgeInsets.all(14),
            child: LegoNetworkImage(
              url: legoSet.imageUrl,
              fit: BoxFit.contain,
              cacheWidth: 600,
              cacheHeight: 600,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            LegoBadgePill(
              text: '$slotLabel · #${legoSet.setNumber.orPlaceholder()}',
              backgroundColor: LegoCatalogApp.legoRed,
              textColor: Colors.white,
            ),
            LegoBadgePill(
              text: 'AGE ${legoSet.ageRating.orPlaceholder()}',
              backgroundColor: LegoCatalogApp.legoYellow,
              textColor: LegoCatalogApp.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 38),
          child: Text(
            legoSet.name.orPlaceholder().toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: LegoCatalogApp.textPrimary,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openSetDetail(context, legoSet),
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
              child: const Text(
                'VIEW DETAILS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: LegoCatalogApp.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompareMetricRow extends StatelessWidget {
  final String label;
  final String valueA;
  final String valueB;
  final String? badgeA;
  final String? badgeB;
  final bool greenBadge;
  final bool highlightValue;

  const _CompareMetricRow({
    required this.label,
    required this.valueA,
    required this.valueB,
    this.badgeA,
    this.badgeB,
    this.greenBadge = false,
    this.highlightValue = false,
  });

  Widget _cell(String value, String? badge) {
    final bgColor = greenBadge
        ? const Color(0xFFE6F4EA)
        : LegoCatalogApp.legoYellow;
    final fgColor = greenBadge
        ? const Color(0xFF1E7E34)
        : LegoCatalogApp.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: highlightValue
                ? LegoCatalogApp.legoRed
                : LegoCatalogApp.textPrimary,
            fontFeatures: LegoCatalogApp.tabularNums,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(height: 5),
          LegoBadgePill(
            text: badge,
            backgroundColor: bgColor,
            textColor: fgColor,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: LegoCatalogApp.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _cell(valueA, badgeA)),
              const SizedBox(width: 16),
              Expanded(child: _cell(valueB, badgeB)),
            ],
          ),
        ],
      ),
    );
  }
}
