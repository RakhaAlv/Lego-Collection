import 'package:flutter/foundation.dart';

import '../models/lego_set.dart';

// Singleton + ChangeNotifier agar state Wishlist otomatis sinkron di semua layar & navbar.
class WishlistStore extends ChangeNotifier {
  WishlistStore._();

  static final WishlistStore instance = WishlistStore._();
  factory WishlistStore() => instance;

  final Map<int, LegoSet> _items = {};

  List<LegoSet> get items => _items.values.toList(growable: false);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
  int get totalPriceIdr => _items.values.fold(0, (sum, set) => sum + set.priceIdr);
  bool contains(int id) => _items.containsKey(id);

  // Tambah/hapus set dari Wishlist; return true jika baru ditambahkan.
  bool toggle(LegoSet set) {
    final added = !_items.containsKey(set.id);
    if (added) {
      _items[set.id] = set;
    } else {
      _items.remove(set.id);
    }
    notifyListeners();
    return added;
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
