class RazorpayConfig {
  const RazorpayConfig({
    required this.keyId,
    this.currency = 'INR',
    this.merchantName = 'ShopRite',
    this.themeColor = '#6D2E46',
    this.checkoutTimeout = const Duration(minutes: 5),
  });

  factory RazorpayConfig.defaultConfig() => const RazorpayConfig(
    keyId: String.fromEnvironment(
      'RAZORPAY_KEY_ID',
      defaultValue: 'rzp_test_SlhvLFuvfU78aR',
    ),
  );

  final String keyId;
  final String currency;
  final String merchantName;
  final String themeColor;
  final Duration checkoutTimeout;

  bool get isKeyConfigured => keyId.trim().isNotEmpty;
}
