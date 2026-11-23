import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../services/wishlist_store.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lego_set_card.dart';
import 'set_detail_screen.dart';

/// Tab 4: daftar Set LEGO favorit yang disimpan pengguna ke Wishlist.
class WishlistScreen extends StatelessWidget {
  final ScrollController? scrollController;
  final VoidCallback? onExploreSets;

  const WishlistScreen({
    super.key,
    this.scrollController,
    this.onExploreSets,
  });

  @override
  Widget build(BuildContext context) {
    final store = WishlistStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const LegoAppBarTitle(title: 'Wishlist Koleksi'),
        actions: [
          ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              if (store.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Kosongkan Wishlist',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  store.clear();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Semua set di Wishlist dihapus'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                },
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final items = store.items;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: LegoCatalogApp.legoYellowTint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 40,
                        color: LegoCatalogApp.legoRed,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Wishlist Masih Kosong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: LegoCatalogApp.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tekan ikon hati pada kartu atau halaman detail set LEGO '
                      'untuk menyimpannya ke daftar koleksi impianmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: LegoCatalogApp.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    if (onExploreSets != null) ...[
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: onExploreSets,
                        icon: const Icon(Icons.widgets_outlined),
                        label: const Text('Jelajahi Katalog Set'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: LegoCatalogApp.legoYellowTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: LegoCatalogApp.legoRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${items.length} Set Disimpan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: LegoCatalogApp.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Estimasi total: ${CurrencyFormatter.toRupiah(store.totalPriceIdr)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: LegoCatalogApp.legoRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                    itemExtent: 170,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final setItem = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LegoSetCard(
                          legoSet: setItem,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SetDetailScreen(setId: setItem.id, initialSet: setItem),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
