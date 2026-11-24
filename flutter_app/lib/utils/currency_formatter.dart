import 'package:flutter/material.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static int parseInt(dynamic value) =>
      value is int ? value : int.tryParse('$value') ?? 0;

  // Format angka ke Rupiah bertitik ribuan (mis. 8499000 -> "Rp 8.499.000").
  static String toRupiah(num value) {
    final digits = value.round().abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '${value < 0 ? '-' : ''}Rp $buffer';
  }

  static String thousands(num value) => toRupiah(value).replaceFirst('Rp ', '');

  static String shortTheme(String name) =>
      name == 'LEGO City' ? 'LEGO CITY' : name.replaceFirst('LEGO ', '').toUpperCase();

  static Color themeSwatch(int themeId) {
    return switch (themeId) {
      1 => const Color(0xFFD01012), // Marvel
      2 => const Color(0xFF1E4E8C), // Disney
      3 => const Color(0xFF6B212C), // Harry Potter
      4 => const Color(0xFF1D6F52), // NINJAGO
      5 => const Color(0xFFF6C90E), // LEGO City
      6 => const Color(0xFF1E1E1E), // Star Wars
      _ => const Color(0xFF888888),
    };
  }
}

// Guard agar nilai null/kosong/"null" dari API diganti fallback yang aman.
extension SafeDisplayString on String? {
  String orPlaceholder([String fallback = '-']) {
    final raw = this?.trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') {
      return fallback;
    }
    return raw;
  }
}
