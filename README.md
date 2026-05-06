# ShopRite E-Commerce

ShopRite is a Flutter fashion commerce app inspired by the completeness of modern shopping apps while using its own visual direction: teal editorial surfaces, compact product cards, live cart/wishlist state, checkout, order tracking, and spending analytics.

## Features

- Firebase Auth email/password signup, login, persistent session, logout, and mapped auth errors.
- Firestore-backed collections: `users`, `products`, and per-user `orders`.
- Structured Dart models with `toMap` / `fromMap` serialization.
- Real-time cart and wishlist updates through user document streams.
- Product listing with search, category filtering, details, discounts, ratings, stock state, and optimized cached images.
- Checkout uses Razorpay Test Mode on Android/iOS, with Pay Now and Pay Later order flows.
- Recently viewed products stored locally.
- Search-history recommendations backed by a local Python recommendation service.
- Trending algorithm based on views, add-to-cart frequency, rating, discount, and stock.
- Order analytics chart showing monthly spending.
- Offline handling with cached product list and clear offline/error UI.
- Responsive mobile/tablet grids using `GridView.builder`.
- Widget tests for happy path and edge cases.

## Firebase Setup

1. Create a Firebase project.
2. Enable Email/Password authentication.
3. Create Firestore Database.
4. Add Android/iOS/Web apps as needed.
5. Confirm the generated values in `lib/firebase_options.dart`.

Expected Firestore shape:

```text
users/{userId}
  userId: string
  name: string
  email: string
  wishlist: string[]
  cart: map[]
  orders/{orderId}
    id: string
    orderId: string
    userId: string
    items: map[]
    totalAmount: number
    status: string
    createdAt: timestamp
    phoneNumber: string
    deliveryAddress: string
    paymentStatus: string
    paymentId: string|null
    razorpayOrderId: string
    paymentSignature: string

products/{productId}
  id: string
  name: string
  category: string
  price: number
  discount: number
  rating: number
  imageUrl: string
  stock: number
  views: number
  addToCartCount: number

```

## Custom Logic

The recommendation engine scores products using the user's recent product searches. Flutter sends product data and search history to `python_recommender/recommendation_server.py`, which returns ranked product ids.

The trending system ranks products using:

- views
- add-to-cart frequency
- rating
- discount
- stock availability

## Analytics Insight

The order analytics chart shows monthly spending. The insight it provides: users can see which months drive higher fashion spend and plan future purchases around discount seasons.

## Razorpay Test Payment

`lib/config/razorpay_config.dart` contains client-side Razorpay configuration, `lib/services/razorpay_service.dart` owns the Razorpay SDK event listeners, `lib/state/checkout_provider.dart` handles Pay Now / Pay Later checkout state, and `lib/state/order_provider.dart` handles pending-order payment updates. Razorpay's Flutter SDK supports Android and iOS. Test keys do not move real money.

Checkout supports two payment modes:

- Pay Now: opens Razorpay before creating the order; successful payments create an order with `paymentStatus: paid`.
- Pay Later: creates the order immediately with `paymentStatus: pending`; order history shows a Pay Now button for pending orders.

1. Create or open a Razorpay account.
2. Switch the Razorpay Dashboard to Test Mode.
3. Copy the Test Mode `Key ID` and `Key Secret`.
4. Check the simple config files:

```powershell
notepad lib\config\razorpay_config.dart
notepad python_payment_server\razorpay_server_config.py
```

5. Start the local payment server:

```powershell
.\scripts\start_razorpay_server.ps1
```

6. In another terminal, run Flutter on Android emulator:

```powershell
.\scripts\run_razorpay_android.ps1
```

The Flutter app now points directly to `http://10.255.104.58:8790`. If your Wi-Fi IP changes, update that single value in `lib/config/razorpay_config.dart`.

## How To Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

On Windows, Flutter plugins may require Developer Mode for symlink support:

```powershell
start ms-settings:developers
```

## Notes

Firebase is initialized from `lib/firebase_options.dart`. Firebase integration code is already present in repositories and services.
