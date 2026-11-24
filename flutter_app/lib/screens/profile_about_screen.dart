import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/lego_set_card.dart' show LegoAppBarTitle, LegoNetworkImage;

class ProfileAboutScreen extends StatelessWidget {
  final ScrollController? scrollController;

  const ProfileAboutScreen({super.key, this.scrollController});

  static const String appVersion = '1.0.0';
  static const String profileAvatarUrl =
      'https://www.brickifyme.com/roy-lego-profile.png';

  Widget _row({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: LegoCatalogApp.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: LegoCatalogApp.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 28;

    Widget content = Scaffold(
      appBar: AppBar(title: const LegoAppBarTitle(title: 'PROFILE')),
      body: Scrollbar(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: LegoCatalogApp.textPrimary,
                        border: Border(
                          top: BorderSide(
                            color: LegoCatalogApp.legoYellow,
                            width: 4,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: LegoCatalogApp.legoYellow,
                                width: 2.5,
                              ),
                            ),
                            child: const LegoNetworkImage(
                              url: profileAvatarUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 260,
                              cacheHeight: 260,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'RAKHA ALJIVA PRABASWARA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'LEGO INSIDERS',
                            style: TextStyle(
                              color: LegoCatalogApp.legoYellow,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: LegoCatalogApp.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _row(
                            label: 'FULL NAME',
                            value: 'Rakha Aljiva Prabaswara',
                          ),
                          const Divider(),
                          _row(label: 'NIM', value: '21120124140126'),
                          const Divider(),
                          _row(label: 'MEMBERSHIP', value: 'LEGO Insiders'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'ABOUT LEGO COLLECTION',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: LegoCatalogApp.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: LegoCatalogApp.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _row(
                            label: 'LEGO COLLECTION CATALOG',
                            value:
                                'An interactive catalog curated for exploring iconic LEGO '
                                'collections across six official themes, comparing two sets '
                                'side by side, and saving favorite builds to your Wishlist.',
                          ),
                          const Divider(),
                          _row(label: 'APP VERSION', value: appVersion),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '© 2026 Rakha Aljiva Prabaswara\nLEGO® is a trademark of the LEGO Group.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: LegoCatalogApp.textSecondary,
                        height: 1.5,
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

    if (scrollController != null) {
      content = PrimaryScrollController(
        controller: scrollController!,
        child: content,
      );
    }
    return Title(
      color: LegoCatalogApp.legoYellow,
      title: 'Profile | LEGO COLLECTION',
      child: content,
    );
  }
}
