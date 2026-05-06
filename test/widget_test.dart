import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_rite_ecommerce/app.dart';
import 'package:shop_rite_ecommerce/core/utils/network_checker.dart';
import 'package:shop_rite_ecommerce/models/product_model.dart';
import 'package:shop_rite_ecommerce/providers/product_provider.dart';
import 'package:shop_rite_ecommerce/repositories/product_repository.dart';
import 'package:shop_rite_ecommerce/screens/product/product_list_screen.dart';
import 'package:shop_rite_ecommerce/services/payment_service.dart';
import 'package:shop_rite_ecommerce/state/payment_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('edge case: invalid login shows validation errors', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('edge case: empty cart shows placeholder', (tester) async {
    await tester.pumpWidget(_testApp());
    await _login(tester);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your cart is empty. Add something good.'),
      findsOneWidget,
    );
  });

  testWidgets('edge case: no internet shows fallback UI', (tester) async {
    final provider = ProductProvider(
      repository: _OfflineProductRepository(),
      networkChecker: _OfflineNetworkChecker(),
    )..loadProducts();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Products could not be loaded. Check your connection.'),
      findsOneWidget,
    );
  });

  testWidgets('happy path: login, add to cart, checkout', (tester) async {
    await tester.pumpWidget(_testApp());
    await _login(tester);
    await tester.pump(const Duration(milliseconds: 500));

    while (find.text('Add').evaluate().isEmpty) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Add').first);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('Place order'), findsOneWidget);
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '9876543210',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Delivery address'),
      '221 Market Street, Central City',
    );
    await tester.tap(find.text('Pay now'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Payment successful'), findsOneWidget);
    await tester.tap(find.text('Track order'));
    await tester.pumpAndSettle();

    expect(find.text('Track order'), findsOneWidget);
    expect(find.text('Placed'), findsOneWidget);
  });
}

Widget _testApp() {
  return ShopRiteApp(
    overrides: [
      paymentServiceProvider.overrideWithValue(_FakePaymentService()),
    ],
  );
}

Future<void> _login(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 950));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byType(TextFormField).first,
    'buyer@shoprite.test',
  );
  await tester.enterText(find.byType(TextFormField).last, 'strong123');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}

class _OfflineProductRepository extends ProductRepository {
  @override
  Stream<List<ProductModel>> watchProducts() {
    return Stream<List<ProductModel>>.error(Exception('offline'));
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async => const [];
}

class _OfflineNetworkChecker extends NetworkChecker {
  @override
  Stream<bool> get onStatusChanged => const Stream<bool>.empty();

  @override
  Future<bool> get isConnected async => false;
}

class _FakePaymentService extends PaymentService {
  _FakePaymentService();

  @override
  Future<PaymentResult> openCheckout({
    required int amount,
    required String userId,
    required String orderId,
    required String email,
    required String phoneNumber,
  }) async {
    return const PaymentResult(
      paymentId: 'pay_test_success',
      razorpayOrderId: 'order_test_success',
      signature: 'signature_test_success',
    );
  }
}
