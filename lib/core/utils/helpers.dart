class Helpers {
  const Helpers._();

  static String formatCurrency(num amount) {
    final prefix = amount < 0 ? '-Rs. ' : 'Rs. ';
    return '$prefix${amount.abs().toStringAsFixed(2)}';
  }

  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
