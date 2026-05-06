# ShopRite E-Commerce

ShopRite is a Flutter fashion commerce app inspired by the completeness of modern shopping apps while using its own visual direction: teal editorial surfaces, compact product cards, live cart/wishlist state, checkout, order tracking, and spending analytics.

## Features

- Firebase Auth email/password signup, login, persistent session, logout, and mapped auth errors.
- Firebase-backed user/product data with demo in-memory cart, wishlist, order, and payment history.
- Structured Dart models with `toMap` / `fromMap` serialization.
- In-memory cart, wishlist, order, and payment history for the demo checkout flow.
- Product listing with search, category filtering, details, discounts, ratings, stock state, and optimized cached images.
- Checkout uses Razorpay Test Mode on Android/iOS, with Pay Now and Pay Later order flows.
- Recently viewed products stored locally.
- Search-history recommendations using the in-app recommendation engine.
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

Expected Firestore shape for Firebase-backed user/product data:

```text
users/{userId}
  userId: string
  name: string
  email: string
  wishlist: string[]

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

The recommendation engine scores products in Dart using the user's recent product searches, ratings, stock, discounts, and engagement data.

The trending system ranks products using:

- views
- add-to-cart frequency
- rating
- discount
- stock availability

## Analytics Insight

The order analytics chart shows monthly spending. The insight it provides: users can see which months drive higher fashion spend and plan future purchases around discount seasons.

## Razorpay Test Payment

`lib/config/razorpay_config.dart` contains client-side Razorpay configuration, `lib/services/payment_service.dart` owns the Razorpay SDK event listeners, `lib/state/checkout_provider.dart` handles Pay Now / Pay Later checkout state, `lib/state/order_provider.dart` handles pending-order payment updates, and `lib/repositories/payment_repository.dart` stores demo payment history in app memory. Razorpay's Flutter SDK supports Android and iOS. Test keys do not move real money.

Checkout supports two payment modes:

- Pay Now: opens Razorpay before creating the order; successful payments create an order with `paymentStatus: paid` and a payment history entry.
- Pay Later: creates the order immediately with `paymentStatus: pending`; order history shows a Pay Now button for pending orders.

1. Create or open a Razorpay account.
2. Switch the Razorpay Dashboard to Test Mode.
3. Copy the Test Mode `Key ID`.
4. Update the Flutter config if you want to replace the bundled test key:

```powershell
notepad lib\config\razorpay_config.dart
```

You can also pass a key at run time:

```powershell
flutter run --dart-define=RAZORPAY_KEY_ID=your_test_key_id
```

The Flutter app opens Razorpay Checkout directly through `razorpay_flutter`; it does not call a local payment API.

For the current demo flow, cart, wishlist, orders, and payments are local in-memory app state. They appear instantly after successful payment and are cleared when the app process restarts.

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
