import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../services/wishlist_store.dart';
import '../utils/currency_formatter.dart';

/// Judul AppBar dengan logo resmi LEGO di sisi kiri via Image.network + fallback aman.
class LegoAppBarTitle extends StatelessWidget {
  final String title;

  const LegoAppBarTitle({super.key, required this.title});

  static const String officialLogoUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/LEGO_logo.svg/500px-LEGO_logo.svg.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Image.network(
              officialLogoUrl,
              fit: BoxFit.cover,
              cacheWidth: 120,
              cacheHeight: 120,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(
                      color: LegoCatalogApp.legoRed,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
              errorBuilder: (context, error, stack) => Container(
                color: LegoCatalogApp.legoRed,
                alignment: Alignment.center,
                child: const Text(
                  'LEGO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Gambar jaringan dengan loading placeholder & fallback error serta decode cache optimal.
class LegoNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final FilterQuality filterQuality;

  const LegoNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.cacheWidth = 480,
    this.cacheHeight,
    this.filterQuality = FilterQuality.low,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Image.network(
        url,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        filterQuality: filterQuality,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(
                color: const Color(0xFFF2F2F2),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: LegoCatalogApp.legoRed,
                  ),
                ),
              ),
        errorBuilder: (context, error, stack) => Container(
          color: const Color(0xFFF2F2F2),
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 38,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}

/// Badge kecil bergaya katalog produk LEGO (dipakai ulang pada kartu & detail).
class LegoBadgePill extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const LegoBadgePill({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFFF2F2F2),
    this.textColor = const Color(0xFF4A4A4A),
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegoSetCard extends StatelessWidget {
  final LegoSet legoSet;
  final VoidCallback onTap;

  const LegoSetCard({super.key, required this.legoSet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wishlist = WishlistStore.instance;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 116,
                  height: 116,
                  child: LegoNetworkImage(
                    url: legoSet.imageUrl,
                    cacheWidth: 240,
                    cacheHeight: 240,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        LegoBadgePill(
                          text: '#${legoSet.setNumber}',
                          backgroundColor: LegoCatalogApp.legoYellowTint,
                          textColor: LegoCatalogApp.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: LegoBadgePill(
                            text: legoSet.theme,
                            backgroundColor: const Color(0xFFF2F2F2),
                            textColor: const Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ListenableBuilder(
                          listenable: wishlist,
                          builder: (context, _) {
                            final saved = wishlist.contains(legoSet.id);
                            return IconButton(
                              tooltip: saved ? 'Hapus dari Wishlist' : 'Simpan ke Wishlist',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              icon: Icon(
                                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 20,
                                color: saved ? LegoCatalogApp.legoRed : const Color(0xFF888888),
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
                    const SizedBox(height: 4),
                    Text(
                      legoSet.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LegoCatalogApp.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          _MetaInfo(
                            icon: Icons.extension_outlined,
                            text: '${CurrencyFormatter.thousands(legoSet.pieces)} pcs',
                          ),
                          const SizedBox(width: 10),
                          _MetaInfo(
                            icon: Icons.person_outline,
                            text: legoSet.ageRating,
                          ),
                          const SizedBox(width: 10),
                          _MetaInfo(
                            icon: Icons.calendar_today_outlined,
                            text: '${legoSet.releaseYear}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            CurrencyFormatter.toRupiah(legoSet.priceIdr),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: LegoCatalogApp.legoRed,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Color(0xFF888888),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: LegoCatalogApp.textSecondary),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: LegoCatalogApp.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
