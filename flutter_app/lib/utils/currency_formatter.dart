/// Format angka ke Rupiah tanpa dependency tambahan, contoh: 3399000 -> "Rp 3.399.000".
class CurrencyFormatter {
  CurrencyFormatter._();

  static String toRupiah(num value) {
    final digits = value.round().abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '${value < 0 ? '-' : ''}Rp ${buffer.toString()}';
  }

  /// Format angka biasa dengan pemisah ribuan, contoh: 1432 -> "1.432".
  static String thousands(num value) => toRupiah(value).replaceFirst('Rp ', '');
}
