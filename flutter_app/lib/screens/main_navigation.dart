import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../services/api_service.dart';
import '../services/wishlist_store.dart';
import 'compare_sets_screen.dart';
import 'home_screen.dart';
import 'profile_about_screen.dart';
import 'sets_list_screen.dart';
import 'wishlist_screen.dart';

class MainNavigation extends StatefulWidget {
  final ApiService? apiService;

  const MainNavigation({super.key, this.apiService});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Nested Navigator agar SetDetailScreen tampil di atas tab tanpa menyembunyikan Bottom Navbar.
  final GlobalKey<NavigatorState> _bodyNavKey = GlobalKey<NavigatorState>();
  final ValueNotifier<int> _tabIndex = ValueNotifier<int>(0);
  final List<ScrollController> _scrollControllers =
      List.generate(5, (_) => ScrollController());

  // Sinyal untuk meneruskan pilihan tema dari Home langsung ke filter Catalog.
  final ValueNotifier<int?> _catalogThemeRequest = ValueNotifier<int?>(null);
  int _catalogRequestVersion = 0;

  late final List<Widget> _pages = [
    HomeScreen(
      scrollController: _scrollControllers[0],
      apiService: widget.apiService,
      onOpenCatalog: _openCatalogWithTheme,
      onOpenCompare: () => _selectTab(2),
    ),
    SetsListScreen(
      scrollController: _scrollControllers[1],
      apiService: widget.apiService,
      themeFilterSignal: _catalogThemeRequest,
    ),
    CompareSetsScreen(
      scrollController: _scrollControllers[2],
      apiService: widget.apiService,
    ),
    WishlistScreen(
      scrollController: _scrollControllers[3],
      onExploreSets: () => _selectTab(1),
    ),
    ProfileAboutScreen(scrollController: _scrollControllers[4]),
  ];

  @override
  void dispose() {
    for (final c in _scrollControllers) {
      c.dispose();
    }
    _tabIndex.dispose();
    _catalogThemeRequest.dispose();
    super.dispose();
  }

  void _openCatalogWithTheme(int? themeId) {
    FocusManager.instance.primaryFocus?.unfocus();
    _bodyNavKey.currentState?.popUntil((route) => route.isFirst);
    _catalogRequestVersion++;
    _catalogThemeRequest.value = themeId ?? -_catalogRequestVersion;
    _tabIndex.value = 1;

    final c = _scrollControllers[1];
    if (c.hasClients && c.offset > 0) {
      c.jumpTo(0);
    }
  }

  // Pindah tab sekaligus menutup SetDetailScreen jika sedang terbuka; ketuk ulang tab aktif untuk gulir ke atas.
  void _selectTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();

    final nav = _bodyNavKey.currentState;
    final wasInDetail = nav != null && nav.canPop();
    if (wasInDetail) {
      nav.popUntil((route) => route.isFirst);
    }

    if (index == _tabIndex.value) {
      if (!wasInDetail) {
        final controller = _scrollControllers[index];
        if (controller.hasClients && controller.offset > 0) {
          controller.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
      return;
    }

    _tabIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistStore.instance;

    return PopScope(
      canPop: false,
      // Tombol Back menutup SetDetailScreen lebih dulu sebelum keluar dari shell navigasi.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _bodyNavKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        }
      },
      child: Scaffold(
        body: Navigator(
          key: _bodyNavKey,
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => ValueListenableBuilder<int>(
              valueListenable: _tabIndex,
              builder: (_, currentIndex, _) => IndexedStack(
                index: currentIndex,
                children: _pages,
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: LegoCatalogApp.borderLight)),
          ),
          child: ListenableBuilder(
            listenable: Listenable.merge([_tabIndex, wishlist]),
            builder: (context, _) {
              final count = wishlist.count;
              return NavigationBar(
                selectedIndex: _tabIndex.value,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: _selectTab,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_filled),
                    label: 'HOME',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view_sharp),
                    label: 'CATALOG',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.compare_arrows_outlined),
                    selectedIcon: Icon(Icons.compare_arrows_rounded),
                    label: 'COMPARE',
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: count > 0,
                      backgroundColor: LegoCatalogApp.legoRed,
                      label: Text(
                        '$count',
                        style: const TextStyle(fontFeatures: LegoCatalogApp.tabularNums),
                      ),
                      child: const Icon(Icons.favorite_outline_rounded),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: count > 0,
                      backgroundColor: LegoCatalogApp.legoRed,
                      label: Text(
                        '$count',
                        style: const TextStyle(fontFeatures: LegoCatalogApp.tabularNums),
                      ),
                      child: const Icon(Icons.favorite_rounded),
                    ),
                    label: 'WISHLIST',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'PROFILE',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
