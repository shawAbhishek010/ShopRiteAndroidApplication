import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../config/razorpay_config.dart';

class PaymentResult {
  const PaymentResult({
    required this.paymentId,
    this.razorpayOrderId = '',
    this.signature = '',
  });

  final String paymentId;
  final String razorpayOrderId;
  final String signature;
}

class PaymentService {
  PaymentService({RazorpayConfig? config, Razorpay? razorpay})
    : _config = config ?? RazorpayConfig.defaultConfig(),
      _razorpay = razorpay;

  final RazorpayConfig _config;
  Razorpay? _razorpay;
  bool _isCheckoutOpen = false;

  Future<PaymentResult> openCheckout({
    required int amount,
    required String userId,
    required String orderId,
    required String email,
    required String phoneNumber,
  }) async {
    if (_isCheckoutOpen) {
      throw Exception('A payment is already in progress.');
    }

    if (amount <= 0) {
      throw Exception('Payment amount must be greater than zero.');
    }

    if (userId.isEmpty || orderId.isEmpty) {
      throw Exception('Payment requires a valid user and order.');
    }

    if (!_config.isKeyConfigured) {
      throw Exception('Razorpay test key is not configured.');
    }

    if (!_supportsRazorpaySdk) {
      throw Exception('Razorpay checkout works on Android and iOS only.');
    }

    final razorpay = _razorpay ??= Razorpay();
    final completer = Completer<PaymentResult>();
    _isCheckoutOpen = true;

    void completeOnce(FutureOr<PaymentResult> Function() callback) {
      if (completer.isCompleted) return;
      try {
        final result = callback();
        if (result is Future<PaymentResult>) {
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
        developer.log(
          'Razorpay payment success paymentId=$paymentId orderId=$orderId',
          name: 'PaymentService',
        );
        return PaymentResult(
          paymentId: paymentId,
          razorpayOrderId: response.orderId ?? '',
          signature: response.signature ?? '',
        );
      });
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
      PaymentFailureResponse response,
    ) {
      completeOnce(() {
        developer.log(
          'Razorpay payment failed code=${response.code} message=${response.message}',
          name: 'PaymentService',
        );
        throw Exception(response.message ?? 'Payment failed or was cancelled.');
      });
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
      ExternalWalletResponse response,
    ) {
      completeOnce(() {
        final walletName = response.walletName ?? 'external wallet';
        developer.log(
          'Razorpay external wallet selected wallet=$walletName',
          name: 'PaymentService',
        );
        throw Exception(
          'Payment moved to $walletName. Please confirm the wallet payment.',
        );
      });
    });

    try {
      razorpay.open({
        'key': _config.keyId,
        'amount': amount,
        'currency': _config.currency,
        'name': _config.merchantName,
        'description': 'ShopRite order #$orderId',
        'prefill': {
          'email': email,
          'contact': phoneNumber.replaceAll(RegExp(r'\D'), ''),
        },
        'notes': {
          'source': 'shop_rite_ecommerce',
          'userId': userId,
          'orderId': orderId,
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

  bool get _supportsRazorpaySdk {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  void dispose() {
    _razorpay?.clear();
  }
}
