import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../services/api_service.dart';
import '../services/wishlist_store.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lego_set_card.dart';

/// Halaman detail Set LEGO, mengambil data dari GET /api/sets/{id}
/// serta set terkait dari GET /api/sets?theme_id={themeId}.
/// Responsif 2 kolom saat lebar layar >= 720px, dan bertumpuk rapi di layar sempit.
class SetDetailScreen extends StatefulWidget {
  final int setId;

  /// Data awal dari list (opsional) untuk judul awal di AppBar.
  final LegoSet? initialSet;

  const SetDetailScreen({super.key, required this.setId, this.initialSet});

  @override
  State<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends State<SetDetailScreen> {
  final ApiService _api = ApiService();
  late Future<LegoSet> _futureSet;
  late Future<List<LegoSet>> _futureRelated;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureSet = _api.fetchSetById(widget.setId);
    _futureRelated = _fetchRelated();
  }

  Future<List<LegoSet>> _fetchRelated() async {
    final current = await _futureSet;
    final list = await _api.fetchSets(themeId: current.themeId);
    return list.where((s) => s.id != widget.setId).toList();
  }

  void _retry() => setState(_loadData);

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistStore.instance;

    return FutureBuilder<LegoSet>(
      future: _futureSet,
      builder: (context, snapshot) {
        final legoSet = snapshot.data ?? widget.initialSet;
        final title = legoSet?.name ?? 'Detail Set';

        return Scaffold(
          appBar: AppBar(
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              if (legoSet != null)
                ListenableBuilder(
                  listenable: wishlist,
                  builder: (context, _) {
                    final saved = wishlist.contains(legoSet.id);
                    return IconButton(
                      tooltip: saved ? 'Hapus dari Wishlist' : 'Simpan ke Wishlist',
                      icon: Icon(
                        saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: saved ? LegoCatalogApp.legoRed : LegoCatalogApp.textPrimary,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        final added = wishlist.toggle(legoSet);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                added
                                    ? '${legoSet.name} ditambahkan ke Wishlist'
                                    : '${legoSet.name} dihapus dari Wishlist',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                      },
                    );
                  },
                ),
            ],
          ),
          body: _buildBody(context, snapshot),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<LegoSet> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: LegoCatalogApp.legoRed),
      );
    }
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: LegoCatalogApp.legoRed),
              const SizedBox(height: 12),
              Text('${snapshot.error}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final legoSet = snapshot.data!;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 28;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final photoCard = _PhotoShowcaseCard(imageUrl: legoSet.imageUrl);
        final detailsColumn = _DetailsColumn(
          legoSet: legoSet,
          futureRelated: _futureRelated,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isWide ? 24 : 16,
            isWide ? 24 : 16,
            isWide ? 24 : 16,
            bottomPad,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: detailsColumn),
                        const SizedBox(width: 22),
                        Expanded(flex: 5, child: photoCard),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        photoCard,
                        const SizedBox(height: 14),
                        detailsColumn,
                      ],
                    ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LegoNetworkImage(
              url: imageUrl,
              fit: BoxFit.contain,
              cacheWidth: 600,
              cacheHeight: 600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsColumn extends StatelessWidget {
  final LegoSet legoSet;
  final Future<List<LegoSet>> futureRelated;

  const _DetailsColumn({required this.legoSet, required this.futureRelated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    LegoBadgePill(
                      text: '#${legoSet.setNumber}',
                      backgroundColor: LegoCatalogApp.legoYellowTint,
                      textColor: LegoCatalogApp.textPrimary,
                    ),
                    LegoBadgePill(
                      icon: Icons.category_outlined,
                      text: legoSet.theme,
                      backgroundColor: const Color(0xFFF2F2F2),
                      textColor: const Color(0xFF4A4A4A),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  legoSet.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LegoCatalogApp.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.toRupiah(legoSet.priceIdr),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: LegoCatalogApp.legoRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SpecTile(
                icon: Icons.extension_outlined,
                label: 'Jumlah Keping',
                value: '${CurrencyFormatter.thousands(legoSet.pieces)} pcs',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SpecTile(
                icon: Icons.person_outline,
                label: 'Rating Usia',
                value: legoSet.ageRating,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SpecTile(
                icon: Icons.calendar_today_outlined,
                label: 'Tahun Rilis',
                value: '${legoSet.releaseYear}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SpecTile(
                icon: Icons.straighten_outlined,
                label: 'Dimensi',
                value: legoSet.dimensions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: LegoCatalogApp.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  legoSet.description,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF333333),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Set Terkait di Tema ${legoSet.theme}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: LegoCatalogApp.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<LegoSet>>(
          future: futureRelated,
          builder: (context, relSnap) {
            if (relSnap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: LegoCatalogApp.legoRed),
                ),
              );
            }
            if (relSnap.hasError) {
              return const Text(
                'Gagal memuat set terkait.',
                style: TextStyle(color: LegoCatalogApp.textSecondary),
              );
            }
            final related = relSnap.data ?? [];
            if (related.isEmpty) {
              return const Text(
                'Tidak ada set terkait lainnya di tema ini.',
                style: TextStyle(color: LegoCatalogApp.textSecondary),
              );
            }
            return Column(
              children: related
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LegoSetCard(
                        legoSet: item,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SetDetailScreen(setId: item.id, initialSet: item),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LegoCatalogApp.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LegoCatalogApp.legoYellowTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: LegoCatalogApp.legoRed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: LegoCatalogApp.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: LegoCatalogApp.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
