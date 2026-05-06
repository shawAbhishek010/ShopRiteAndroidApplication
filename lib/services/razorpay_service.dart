import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../config/razorpay_config.dart';

class RazorpayPaymentResult {
  const RazorpayPaymentResult({
    required this.paymentId,
    this.orderId = '',
    this.signature = '',
  });

  final String paymentId;
  final String orderId;
  final String signature;
}

class RazorpayService {
  RazorpayService({
    RazorpayConfig? config,
    Razorpay? razorpay,
    http.Client? client,
  }) : _config = config ?? RazorpayConfig.defaultConfig(),
       _razorpay = razorpay,
       _client = client ?? http.Client();

  final RazorpayConfig _config;
  final http.Client _client;
  Razorpay? _razorpay;
  bool _isCheckoutOpen = false;

  Future<RazorpayPaymentResult> openCheckout({
    required int amount,
    required String email,
    required String phoneNumber,
    String receipt = '',
  }) async {
    if (_isCheckoutOpen) {
      throw Exception('A payment is already in progress.');
    }

    if (amount <= 0) {
      throw Exception('Payment amount must be greater than zero.');
    }

    if (!_config.isKeyConfigured) {
      throw Exception('Razorpay key is not configured.');
    }

    if (!_supportsRazorpaySdk) {
      throw Exception('Razorpay checkout works on Android and iOS only.');
    }

    final orderId = await _createRazorpayOrder(
      amount: amount,
      receipt: receipt.isEmpty
          ? 'shoprite_${DateTime.now().millisecondsSinceEpoch}'
          : receipt,
      email: email,
      phoneNumber: phoneNumber,
    );

    final razorpay = _razorpay ??= Razorpay();
    _isCheckoutOpen = true;
    final completer = Completer<RazorpayPaymentResult>();

    void completeOnce(FutureOr<RazorpayPaymentResult> Function() callback) {
      if (completer.isCompleted) return;
      try {
        final result = callback();
        if (result is Future<RazorpayPaymentResult>) {
          result.then(completer.complete).catchError(completer.completeError);
        } else {
          completer.complete(result);
        }
      } catch (error) {
        completer.completeError(error);
      }
    }

    razorpay.clear();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
      PaymentSuccessResponse response,
    ) {
      completeOnce(() {
        final paymentId = response.paymentId;
        if (paymentId == null || paymentId.isEmpty) {
          throw Exception('Payment completed without a payment id.');
        }
        return RazorpayPaymentResult(
          paymentId: paymentId,
          orderId: response.orderId ?? orderId,
          signature: response.signature ?? '',
        );
      });
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
      PaymentFailureResponse response,
    ) {
      completeOnce(() {
        throw Exception(response.message ?? 'Payment failed or was cancelled.');
      });
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
      ExternalWalletResponse response,
    ) {
      completeOnce(() {
        final walletName = response.walletName ?? 'external wallet';
        throw Exception(
          'Payment moved to $walletName. Please confirm payment.',
        );
      });
    });

    try {
      razorpay.open({
        'key': _config.keyId,
        'amount': amount,
        'currency': _config.currency,
        'name': _config.merchantName,
        'description': 'ShopRite order payment',
        'order_id': orderId,
        'prefill': {
          'email': email,
          'contact': phoneNumber.replaceAll(RegExp(r'\D'), ''),
        },
        'retry': {'enabled': true, 'max_count': 1},
        'theme': {'color': _config.themeColor},
      });
      return await completer.future.timeout(
        _config.checkoutTimeout,
        onTimeout: () =>
            throw Exception('Payment timed out. Please try again.'),
      );
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('Could not open Razorpay checkout. Please try again.');
    } finally {
      _isCheckoutOpen = false;
      razorpay.clear();
    }
  }

  Future<String> _createRazorpayOrder({
    required int amount,
    required String receipt,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_config.orderEndpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount': amount,
              'currency': _config.currency,
              'receipt': receipt,
              'notes': {
                'source': 'shop_rite_ecommerce',
                'email': email,
                'phone': phoneNumber,
              },
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Razorpay order creation failed: ${response.body}');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final id = decoded['id'] as String? ?? '';
      if (id.isEmpty) {
        throw Exception('Razorpay order creation returned no order id.');
      }
      return id;
    } catch (error) {
      throw Exception(
        'Could not create Razorpay order. Check that the Python payment server is running and that the phone can reach ${_config.serverBaseUrl}. $error',
      );
    }
  }

  bool get _supportsRazorpaySdk {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  void dispose() {
    _razorpay?.clear();
    _client.close();
  }
}
