class RazorpayConfig {
  const RazorpayConfig({
    required this.keyId,
    required this.serverBaseUrl,
    this.currency = 'INR',
    this.merchantName = 'ShopRite',
    this.themeColor = '#6D2E46',
    this.checkoutTimeout = const Duration(minutes: 5),
  });

  factory RazorpayConfig.defaultConfig() => const RazorpayConfig(
    keyId: 'rzp_test_SlhvLFuvfU78aR',
    serverBaseUrl: 'http://10.255.104.58:8790',
  );

  final String keyId;
  final String serverBaseUrl;
  final String currency;
  final String merchantName;
  final String themeColor;
  final Duration checkoutTimeout;

  bool get isKeyConfigured => keyId.trim().isNotEmpty;

  String get orderEndpoint => '$serverBaseUrl/create-order';
}
