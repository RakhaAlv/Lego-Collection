import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../services/wishlist_store.dart';
import 'compare_sets_screen.dart';
import 'profile_about_screen.dart';
import 'sets_list_screen.dart';
import 'wishlist_screen.dart';

/// Kerangka utama dengan NavigationBar (Material 3) berisi 4 tab:
/// Sets, Compare, Wishlist, dan Profile.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<ScrollController> _scrollControllers =
      List.generate(4, (_) => ScrollController());

  late final List<Widget> _pages = [
    SetsListScreen(scrollController: _scrollControllers[0]),
    CompareSetsScreen(scrollController: _scrollControllers[1]),
    WishlistScreen(
      scrollController: _scrollControllers[2],
      onExploreSets: () => _selectTab(0),
    ),
    ProfileAboutScreen(scrollController: _scrollControllers[3]),
  ];

  @override
  void dispose() {
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _selectTab(int index) {
    HapticFeedback.selectionClick();
    if (index == _currentIndex) {
      final controller = _scrollControllers[index];
      if (controller.hasClients && controller.offset > 0) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistStore.instance;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: LegoCatalogApp.borderLight)),
        ),
        child: ListenableBuilder(
          listenable: wishlist,
          builder: (context, _) {
            final count = wishlist.count;
            return NavigationBar(
              selectedIndex: _currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: _selectTab,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.widgets_outlined),
                  selectedIcon: Icon(Icons.widgets),
                  label: 'Sets',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.compare_arrows_outlined),
                  selectedIcon: Icon(Icons.compare_arrows_rounded),
                  label: 'Compare',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: count > 0,
                    backgroundColor: LegoCatalogApp.legoRed,
                    label: Text('$count'),
                    child: const Icon(Icons.favorite_outline_rounded),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: count > 0,
                    backgroundColor: LegoCatalogApp.legoRed,
                    label: Text('$count'),
                    child: const Icon(Icons.favorite_rounded),
                  ),
                  label: 'Wishlist',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
