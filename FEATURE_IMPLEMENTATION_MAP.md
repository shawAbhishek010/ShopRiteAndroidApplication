# Feature Implementation Map

This file explains where each required project feature is implemented in the ShopRite E-Commerce app.

## Evaluation Feature Mapping

| Requirement | Main Files | Where It Is Implemented |
| --- | --- | --- |
| Core features | `lib/screens/home/home_screen.dart`, `lib/screens/product/product_list_screen.dart`, `lib/screens/product/product_detail_screen.dart`, `lib/screens/cart/cart_screen.dart`, `lib/screens/order/order_screen.dart`, `lib/screens/wishlist/wishlist_screen.dart` | Shopping home page, product listing, product details, cart, order history, wishlist, checkout, and profile flows are created in these screens. |
| Feature integration | `lib/app.dart`, `lib/routes/app_routes.dart`, `lib/providers/product_provider.dart`, `lib/providers/cart_provider.dart`, `lib/providers/auth_provider.dart` | App-wide providers and routes connect authentication, products, cart, wishlist, orders, and checkout into one working application flow. |
| Extended features 2 | `lib/logic/recommendation_engine.dart`, `lib/logic/trending_algorithm.dart`, `lib/domain/order_analytics.dart`, `lib/screens/payment/payment_history_screen.dart`, `lib/screens/order/order_tracking_screen.dart` | Extended features include recommendations, trending products, spending analytics, payment history, and order tracking. |
| Edge cases handling | `lib/core/utils/validators.dart`, `lib/core/utils/network_checker.dart`, `lib/widgets/error_widget.dart`, `lib/widgets/loading_widget.dart`, `lib/providers/product_provider.dart`, `test/widget_test.dart` | Handles invalid login input, empty cart, offline product loading, loading states, error states, and tested edge cases. |
| Custom design system | `lib/core/constants/app_colors.dart`, `lib/core/constants/app_sizes.dart`, `lib/core/constants/app_strings.dart`, `lib/core/theme/app_theme.dart`, `lib/core/theme/text_styles.dart` | Central design tokens, colors, sizes, strings, app theme, button styles, input styles, card styles, and text styles are defined here. |
| Reusable widget 3 | `lib/widgets/custom_button.dart`, `lib/widgets/custom_textfield.dart`, `lib/widgets/custom_appbar.dart`, `lib/widgets/loading_widget.dart`, `lib/widgets/error_widget.dart`, `lib/widgets/app_background.dart`, `lib/screens/product/widgets/product_card.dart` | Reusable widgets include custom buttons, text fields, app bars, loading UI, error UI, app background, and product card components. |
| Responsiveness | `lib/screens/home/home_screen.dart`, `lib/screens/product/product_list_screen.dart`, `lib/screens/product/product_detail_screen.dart`, `lib/screens/order/order_screen.dart`, `lib/widgets/app_background.dart`, `lib/screens/home/widgets/banner_carousel.dart`, `lib/screens/home/widgets/recommendation_section.dart` | Uses `LayoutBuilder`, responsive grids, adaptive product layouts, and flexible screen sections for mobile and larger screens. |
| Micro interaction | `lib/widgets/animated_add_to_cart_button.dart`, `lib/widgets/cart_micro_interactions.dart`, `lib/screens/home/widgets/category_card.dart`, `lib/screens/order/order_tracking_screen.dart`, `lib/screens/home/widgets/banner_carousel.dart` | Includes animated add-to-cart button, cart pulse/fly animation, category hover/tap animation, order progress animation, and banner carousel transitions. |
| Visual consistency | `lib/core/theme/app_theme.dart`, `lib/core/constants/app_colors.dart`, `lib/widgets/app_background.dart`, `lib/screens/home/widgets/banner_carousel.dart`, `lib/screens/product/widgets/product_card.dart`, `lib/screens/auth/widgets/auth_wallpaper.dart` | Consistent colors, cards, buttons, text styles, backgrounds, product cards, and authentication panels are reused across the app. |
| Proper use of Provider/Bloc | `lib/app.dart`, `lib/providers/auth_provider.dart`, `lib/providers/product_provider.dart`, `lib/providers/cart_provider.dart`, `lib/providers/wishlist_provider.dart`, `lib/providers/theme_provider.dart`, `lib/state/checkout_provider.dart`, `lib/state/order_provider.dart`, `lib/state/payment_provider.dart` | Uses Provider `ChangeNotifier` classes for app state and Riverpod providers/controllers for checkout, orders, and payments. Bloc is not used because Provider and Riverpod are the selected state-management tools. |
| Layer separation | `lib/screens/`, `lib/widgets/`, `lib/providers/`, `lib/state/`, `lib/repositories/`, `lib/services/`, `lib/models/`, `lib/logic/`, `lib/domain/` | UI, reusable widgets, state management, repositories, services, data models, business logic, and domain analytics are separated into different folders. |
| State flow clarity | `lib/app.dart`, `lib/providers/product_provider.dart`, `lib/providers/cart_provider.dart`, `lib/providers/auth_provider.dart`, `lib/state/checkout_provider.dart`, `lib/state/order_provider.dart` | UI reads state from providers, providers call repositories, repositories call services/cache/database, then providers notify the UI when state changes. |
| No setState misuse | `lib/providers/`, `lib/state/`, `lib/screens/admin/admin_dashboard_screen.dart`, `lib/screens/auth/login_screen.dart`, `lib/screens/auth/signup_screen.dart`, `lib/widgets/animated_add_to_cart_button.dart` | App data is managed through Provider/Riverpod. `setState` is only used for local UI-only state such as form loading, selected role, edit mode, button animation, and carousel index. |
| Authentication | `lib/main.dart`, `lib/services/firebase/auth_service.dart`, `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`, `lib/screens/auth/login_screen.dart`, `lib/screens/auth/signup_screen.dart`, `lib/screens/splash/splash_screen.dart` | Firebase is initialized, login/signup/logout are handled, auth state is stored in `AuthProvider`, and splash/auth screens route users based on session state. |
| Database integration | `lib/services/firebase/firestore_service.dart`, `lib/repositories/product_repository.dart`, `lib/repositories/auth_repository.dart`, `lib/repositories/order_repository.dart`, `lib/repositories/payment_repository.dart`, `lib/firebase_options.dart`, `firebase.json`, `android/app/google-services.json` | Firestore is used for users, products, orders, and payments. Firebase configuration files connect the Flutter app to the Firebase project. |

## Important App Flow Files

| Flow | Files |
| --- | --- |
| App start and dependency injection | `lib/main.dart`, `lib/app.dart` |
| Routing | `lib/routes/app_routes.dart` |
| Login and signup | `lib/screens/auth/login_screen.dart`, `lib/screens/auth/signup_screen.dart`, `lib/providers/auth_provider.dart`, `lib/repositories/auth_repository.dart`, `lib/services/firebase/auth_service.dart` |
| Product catalog | `lib/screens/product/product_list_screen.dart`, `lib/screens/product/product_detail_screen.dart`, `lib/providers/product_provider.dart`, `lib/repositories/product_repository.dart`, `lib/services/api/product_api.dart` |
| Admin product management | `lib/screens/admin/admin_dashboard_screen.dart`, `lib/providers/product_provider.dart`, `lib/repositories/product_repository.dart`, `lib/services/firebase/firestore_service.dart` |
| Cart and checkout | `lib/screens/cart/cart_screen.dart`, `lib/providers/cart_provider.dart`, `lib/repositories/cart_repository.dart`, `lib/state/checkout_provider.dart` |
| Orders | `lib/screens/order/order_screen.dart`, `lib/screens/order/order_tracking_screen.dart`, `lib/state/order_provider.dart`, `lib/repositories/order_repository.dart` |
| Payments | `lib/services/payment_service.dart`, `lib/state/payment_provider.dart`, `lib/repositories/payment_repository.dart`, `lib/screens/payment/payment_history_screen.dart` |
| Wishlist | `lib/screens/wishlist/wishlist_screen.dart`, `lib/providers/wishlist_provider.dart` |
| Recommendations and trending | `lib/logic/recommendation_engine.dart`, `lib/logic/trending_algorithm.dart`, `lib/screens/home/widgets/recommendation_section.dart` |
| Local cache and offline support | `lib/services/local/cache_service.dart`, `lib/core/utils/network_checker.dart`, `lib/providers/product_provider.dart` |

## Architecture Summary

The app follows a clear Flutter architecture:

1. `screens/` display UI and user flows.
2. `widgets/` provide reusable UI components.
3. `providers/` and `state/` manage app state.
4. `repositories/` coordinate app data operations.
5. `services/` communicate with Firebase, Razorpay, local cache, or demo APIs.
6. `models/` define structured data objects.
7. `logic/` and `domain/` contain business rules such as recommendation, trending, and analytics.

This separation keeps UI, state, database, and business logic easy to understand and maintain.
