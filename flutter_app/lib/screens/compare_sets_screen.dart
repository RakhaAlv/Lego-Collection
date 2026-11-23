import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../services/api_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lego_set_card.dart' show LegoAppBarTitle, LegoBadgePill, LegoNetworkImage;
import 'set_detail_screen.dart';

/// Tab 2: Perbandingan 2 Set LEGO secara berdampingan.
class CompareSetsScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final ApiService? apiService;

  const CompareSetsScreen({
    super.key,
    this.scrollController,
    this.apiService,
  });

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
    if (id == null) return null;
    for (final s in _sets) {
      if (s.id == id) return s;
    }
    return _sets.isNotEmpty ? _sets.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegoAppBarTitle(title: 'Bandingkan Set')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: LegoCatalogApp.legoRed),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: LegoCatalogApp.legoRed),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadSets,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final setA = _findSet(_setAId);
    final setB = _findSet(_setBId);
    if (setA == null || setB == null) {
      return const Center(child: Text('Belum ada data set untuk dibandingkan.'));
    }

    final perPieceA = setA.pieces > 0 ? (setA.priceIdr / setA.pieces).round() : 0;
    final perPieceB = setB.pieces > 0 ? (setB.priceIdr / setB.pieces).round() : 0;

    return RefreshIndicator(
      color: LegoCatalogApp.legoRed,
      onRefresh: _loadSets,
      child: Scrollbar(
        controller: widget.scrollController,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih 2 Set untuk Dibandingkan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: LegoCatalogApp.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _SetSelectorDropdown(
                                    key: const ValueKey('compare-dropdown-a'),
                                    label: 'Set A',
                                    value: setA.id,
                                    sets: _sets,
                                    onChanged: (id) {
                                      if (id == null) return;
                                      HapticFeedback.selectionClick();
                                      setState(() => _setAId = id);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SetSelectorDropdown(
                                    key: const ValueKey('compare-dropdown-b'),
                                    label: 'Set B',
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
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _CompareSetHeader(
                                  slotLabel: 'Set A',
                                  legoSet: setA,
                                ),
                              ),
                              const VerticalDivider(width: 20),
                              Expanded(
                                child: _CompareSetHeader(
                                  slotLabel: 'Set B',
                                  legoSet: setB,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Column(
                          children: [
                            _CompareMetricRow(
                              label: 'Nomor Set',
                              valueA: '#${setA.setNumber}',
                              valueB: '#${setB.setNumber}',
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Tema',
                              valueA: setA.theme,
                              valueB: setB.theme,
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Harga',
                              valueA: CurrencyFormatter.toRupiah(setA.priceIdr),
                              valueB: CurrencyFormatter.toRupiah(setB.priceIdr),
                              highlightValue: true,
                              badgeA: setA.priceIdr < setB.priceIdr ? 'Lebih Hemat' : null,
                              badgeB: setB.priceIdr < setA.priceIdr ? 'Lebih Hemat' : null,
                              greenBadge: true,
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Jumlah Keping',
                              valueA: '${CurrencyFormatter.thousands(setA.pieces)} pcs',
                              valueB: '${CurrencyFormatter.thousands(setB.pieces)} pcs',
                              badgeA: setA.pieces > setB.pieces ? 'Lebih Banyak' : null,
                              badgeB: setB.pieces > setA.pieces ? 'Lebih Banyak' : null,
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Harga / Keping',
                              valueA: '${CurrencyFormatter.toRupiah(perPieceA)} / pcs',
                              valueB: '${CurrencyFormatter.toRupiah(perPieceB)} / pcs',
                              badgeA: perPieceA > 0 && perPieceB > 0 && perPieceA < perPieceB
                                  ? 'Lebih Hemat'
                                  : null,
                              badgeB: perPieceA > 0 && perPieceB > 0 && perPieceB < perPieceA
                                  ? 'Lebih Hemat'
                                  : null,
                              greenBadge: true,
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Rating Usia',
                              valueA: setA.ageRating,
                              valueB: setB.ageRating,
                            ),
                            const Divider(),
                            _CompareMetricRow(
                              label: 'Tahun Rilis',
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
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: LegoCatalogApp.textPrimary,
        ),
        filled: true,
        fillColor: LegoCatalogApp.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: LegoCatalogApp.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: LegoCatalogApp.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: LegoCatalogApp.legoRed, width: 1.5),
        ),
      ),
      items: sets
          .map(
            (s) => DropdownMenuItem<int>(
              value: s.id,
              child: Text(
                '#${s.setNumber} - ${s.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: LegoCatalogApp.textPrimary),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LegoNetworkImage(
              url: legoSet.imageUrl,
              fit: BoxFit.contain,
              cacheWidth: 600,
              cacheHeight: 600,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            LegoBadgePill(
              text: '$slotLabel • #${legoSet.setNumber}',
              backgroundColor: LegoCatalogApp.legoYellowTint,
              textColor: LegoCatalogApp.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          legoSet.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: LegoCatalogApp.textPrimary,
            height: 1.25,
          ),
        ),
        const Spacer(),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SetDetailScreen(setId: legoSet.id, initialSet: legoSet),
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: LegoCatalogApp.legoRed,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 15),
            label: const Text(
              'Lihat Detail',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
    final bgColor = greenBadge ? const Color(0xFFE6F4EA) : LegoCatalogApp.legoYellowTint;
    final fgColor = greenBadge ? const Color(0xFF1E7E34) : LegoCatalogApp.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: highlightValue ? LegoCatalogApp.legoRed : LegoCatalogApp.textPrimary,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(height: 4),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: LegoCatalogApp.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _cell(valueA, badgeA)),
              const SizedBox(width: 12),
              Expanded(child: _cell(valueB, badgeB)),
            ],
          ),
        ],
      ),
    );
  }
}
