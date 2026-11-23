import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/lego_set_card.dart' show LegoAppBarTitle, LegoBadgePill;

/// Tab 5: Profil pengembang & informasi ringkas aplikasi.
class ProfileAboutScreen extends StatelessWidget {
  final ScrollController? scrollController;

  const ProfileAboutScreen({super.key, this.scrollController});

  static const String appVersion = '1.0.0';

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isThreeLine = false,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: LegoCatalogApp.legoYellowTint,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: LegoCatalogApp.legoRed),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: LegoCatalogApp.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14.5,
          color: LegoCatalogApp.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      isThreeLine: isThreeLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const LegoAppBarTitle(title: 'Profile & About')),
      body: Scrollbar(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(height: 8, color: LegoCatalogApp.legoYellow),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 42,
                          backgroundColor: LegoCatalogApp.legoRed,
                          child: Text(
                            'RA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Rakha Aljiva Prabaswara',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: LegoCatalogApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const LegoBadgePill(
                          icon: Icons.verified_outlined,
                          text: 'Pengembang Aplikasi',
                          backgroundColor: LegoCatalogApp.legoYellowTint,
                          textColor: LegoCatalogApp.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _tile(
                    icon: Icons.person_outline,
                    title: 'Nama',
                    subtitle: 'Rakha Aljiva Prabaswara',
                  ),
                  const Divider(),
                  _tile(
                    icon: Icons.badge_outlined,
                    title: 'NIM',
                    subtitle: '21120124140126',
                  ),
                  const Divider(),
                  _tile(
                    icon: Icons.groups_outlined,
                    title: 'Kelompok / Shift',
                    subtitle: 'Kelompok 9 / Shift 02',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Tentang Aplikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LegoCatalogApp.textPrimary,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  _tile(
                    icon: Icons.widgets_outlined,
                    title: 'Aplikasi Katalog Koleksi Set LEGO',
                    subtitle:
                        'Katalog interaktif untuk menjelajahi koleksi set LEGO, mencari dan '
                        'memfilter tema, membandingkan 2 set secara langsung, serta menyimpan daftar '
                        'Wishlist.',
                    isThreeLine: true,
                  ),
                  const Divider(),
                  _tile(
                    icon: Icons.info_outline,
                    title: 'Versi Aplikasi',
                    subtitle: appVersion,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                '© 2026 Rakha Aljiva Prabaswara\nLEGO® adalah merek dagang milik LEGO Group.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: LegoCatalogApp.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
