import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../services/wishlist_store.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lego_set_card.dart';

// Halaman daftar set favorit yang tersimpan di WishlistStore.
class WishlistScreen extends StatelessWidget {
  final ScrollController? scrollController;
  final VoidCallback? onExploreSets;

  const WishlistScreen({super.key, this.scrollController, this.onExploreSets});

  @override
  Widget build(BuildContext context) {
    final store = WishlistStore.instance;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 20;

    Widget content = Scaffold(
      appBar: AppBar(
        title: const LegoAppBarTitle(title: 'WISHLIST'),
        actions: [
          ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              if (store.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  store.clear();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('All saved sets removed from Wishlist'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                },
                style: TextButton.styleFrom(
                  foregroundColor: LegoCatalogApp.legoRed,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'CLEAR ALL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
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
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: LegoCatalogApp.borderLight),
                      ),
                      child: const Icon(
                        Icons.favorite_border_sharp,
                        size: 28,
                        color: LegoCatalogApp.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'YOUR WISHLIST IS EMPTY',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: LegoCatalogApp.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the heart icon on any LEGO set in the catalog '
                      'to save your favorite builds here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: LegoCatalogApp.textSecondary,
                        height: 1.55,
                      ),
                    ),
                    if (onExploreSets != null) ...[
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: onExploreSets,
                        child: const Text('EXPLORE CATALOG'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: LegoCatalogApp.borderLight),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${items.length} ${items.length == 1 ? 'SAVED SET' : 'SAVED SETS'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        letterSpacing: 1.3,
                        color: LegoCatalogApp.textPrimary,
                        fontFeatures: LegoCatalogApp.tabularNums,
                      ),
                    ),
                    Text(
                      'ESTIMATED TOTAL: ${CurrencyFormatter.toRupiah(store.totalPriceIdr)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: LegoCatalogApp.legoRed,
                        fontFeatures: LegoCatalogApp.tabularNums,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                    itemExtent: 158,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final setItem = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LegoSetCard(
                          legoSet: setItem,
                          onTap: () => openSetDetail(context, setItem),
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

    if (scrollController != null) {
      content = PrimaryScrollController(
        controller: scrollController!,
        child: content,
      );
    }
    return Title(
      color: LegoCatalogApp.legoYellow,
      title: 'Wishlist | LEGO COLLECTION',
      child: content,
    );
  }
}
