import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/lego_set.dart';
import '../screens/set_detail_screen.dart';
import '../services/api_service.dart';
import '../services/wishlist_store.dart';
import '../utils/currency_formatter.dart';

// Helper navigasi ke detail set di dalam nested Navigator agar Bottom Navbar tetap terlihat.
void openSetDetail(BuildContext context, LegoSet item, {ApiService? apiService}) {
  FocusManager.instance.primaryFocus?.unfocus();
  HapticFeedback.selectionClick();
  Navigator.push(
    context,
    MaterialPageRoute(
      settings: RouteSettings(name: '/set/${item.id}'),
      builder: (_) => SetDetailScreen(
        setId: item.id,
        initialSet: item,
        apiService: apiService,
      ),
    ),
  );
}

void toggleWishlistWithFeedback(BuildContext context, LegoSet legoSet) {
  HapticFeedback.selectionClick();
  final added = WishlistStore.instance.toggle(legoSet);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${legoSet.name} added to Wishlist'
              : '${legoSet.name} removed from Wishlist',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}

class LegoLoadingState extends StatelessWidget {
  const LegoLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: LegoCatalogApp.textPrimary,
      ),
    );
  }
}

class LegoErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const LegoErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: LegoCatalogApp.legoRed),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: LegoCatalogApp.textPrimary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}

class LegoAppBarTitle extends StatelessWidget {
  final String title;

  const LegoAppBarTitle({super.key, required this.title});

  static const String officialLogoUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/LEGO_logo.svg/500px-LEGO_logo.svg.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
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
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.8, color: Colors.white),
                    ),
                  ),
            errorBuilder: (context, error, stack) => Container(
              color: LegoCatalogApp.legoRed,
              alignment: Alignment.center,
              child: const Text(
                'LEGO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LegoCatalogApp.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}

// Pembungkus Image.network dengan cacheWidth/cacheHeight dan fallback error aman.
class LegoNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final FilterQuality filterQuality;
  final Color backgroundColor;

  const LegoNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.cacheWidth = 480,
    this.cacheHeight,
    this.filterQuality = FilterQuality.low,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Image.network(
        url,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        filterQuality: filterQuality,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(
                color: backgroundColor,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: LegoCatalogApp.textPrimary,
                  ),
                ),
              ),
        errorBuilder: (context, error, stack) => Container(
          color: backgroundColor,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}

class HorizontalEdgeFade extends StatelessWidget {
  final Widget child;

  const HorizontalEdgeFade({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.black, Colors.black, Colors.transparent],
          stops: [0.0, 0.96, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

class LegoBadgePill extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const LegoBadgePill({
    super.key,
    required this.text,
    this.backgroundColor = LegoCatalogApp.legoRed,
    this.textColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: textColor,
                fontFeatures: LegoCatalogApp.tabularNums,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegoEditorialCard extends StatelessWidget {
  final LegoSet legoSet;
  final VoidCallback onTap;
  final double? width;
  final bool expandImage;

  const LegoEditorialCard({
    super.key,
    required this.legoSet,
    required this.onTap,
    this.width,
    this.expandImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistStore.instance;
    final swatch = CurrencyFormatter.themeSwatch(legoSet.themeId);
    final shortTheme = CurrencyFormatter.shortTheme(legoSet.theme);

    final imageFrame = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: LegoCatalogApp.borderLight),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: LegoNetworkImage(
              url: legoSet.imageUrl,
              fit: BoxFit.contain,
              cacheWidth: 420,
              cacheHeight: 420,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: ListenableBuilder(
              listenable: wishlist,
              builder: (context, _) {
                final saved = wishlist.contains(legoSet.id);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => toggleWishlistWithFeedback(context, legoSet),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: Icon(
                        saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 19,
                        color: saved ? LegoCatalogApp.legoRed : LegoCatalogApp.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expandImage)
          Expanded(child: imageFrame)
        else
          AspectRatio(aspectRatio: 1, child: imageFrame),
        const SizedBox(height: 10),
        Row(
          children: [
            LegoBadgePill(
              text: '#${legoSet.setNumber.orPlaceholder()}',
              backgroundColor: LegoCatalogApp.legoRed,
              textColor: Colors.white,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: LegoBadgePill(
                text: 'AGE ${legoSet.ageRating.orPlaceholder()}',
                backgroundColor: LegoCatalogApp.legoYellow,
                textColor: LegoCatalogApp.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 35,
          child: Text(
            legoSet.name.orPlaceholder().toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              height: 1.3,
              color: LegoCatalogApp.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Flexible(
              child: Text(
                CurrencyFormatter.toRupiah(legoSet.priceIdr),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: LegoCatalogApp.textPrimary,
                  fontFeatures: LegoCatalogApp.tabularNums,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${CurrencyFormatter.thousands(legoSet.pieces)} pcs',
              style: const TextStyle(
                fontSize: 11.5,
                color: LegoCatalogApp.textSecondary,
                fontFeatures: LegoCatalogApp.tabularNums,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: swatch,
                border: Border.all(color: Colors.black12),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$shortTheme  ·  ${legoSet.releaseYear}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: LegoCatalogApp.textSecondary,
                  fontFeatures: LegoCatalogApp.tabularNums,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: width != null ? SizedBox(width: width, child: column) : column,
    );
  }
}

class LegoSetCard extends StatelessWidget {
  final LegoSet legoSet;
  final VoidCallback onTap;

  const LegoSetCard({super.key, required this.legoSet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistStore.instance;
    final swatch = CurrencyFormatter.themeSwatch(legoSet.themeId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: LegoCatalogApp.borderLight),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: LegoCatalogApp.borderLight),
                ),
                padding: const EdgeInsets.all(8),
                child: LegoNetworkImage(
                  url: legoSet.imageUrl,
                  cacheWidth: 240,
                  cacheHeight: 240,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        LegoBadgePill(
                          text: '#${legoSet.setNumber.orPlaceholder()}',
                          backgroundColor: LegoCatalogApp.legoRed,
                          textColor: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        LegoBadgePill(
                          text: legoSet.ageRating.orPlaceholder(),
                          backgroundColor: LegoCatalogApp.legoYellow,
                          textColor: LegoCatalogApp.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Container(width: 9, height: 9, color: swatch),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            CurrencyFormatter.shortTheme(
                              legoSet.theme.orPlaceholder(),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: LegoCatalogApp.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ListenableBuilder(
                          listenable: wishlist,
                          builder: (context, _) {
                            final saved = wishlist.contains(legoSet.id);
                            return IconButton(
                              tooltip: saved ? 'Remove from Wishlist' : 'Save to Wishlist',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                width: 28,
                                height: 28,
                              ),
                              icon: Icon(
                                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 19,
                                color: saved ? LegoCatalogApp.legoRed : LegoCatalogApp.textPrimary,
                              ),
                              onPressed: () => toggleWishlistWithFeedback(context, legoSet),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      legoSet.name.orPlaceholder().toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: LegoCatalogApp.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${CurrencyFormatter.thousands(legoSet.pieces)} pcs  ·  Age ${legoSet.ageRating.orPlaceholder()}  ·  ${legoSet.releaseYear}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: LegoCatalogApp.textSecondary,
                        fontFeatures: LegoCatalogApp.tabularNums,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.toRupiah(legoSet.priceIdr),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LegoCatalogApp.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFeatures: LegoCatalogApp.tabularNums,
                      ),
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
