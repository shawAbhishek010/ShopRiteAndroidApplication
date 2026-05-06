import 'package:flutter/material.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/landing/landing_page.dart';
import '../screens/order/order_screen.dart';
import '../screens/order/order_tracking_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/product_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../widgets/app_background.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const products = '/products';
  static const productDetail = '/product-detail';
  static const cart = '/cart';
  static const wishlist = '/wishlist';
  static const orders = '/orders';
  static const orderTracking = '/order-tracking';
  static const profile = '/profile';
  static const landing = '/landing';
  static const admin = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) {
        switch (settings.name) {
          case splash:
            return _withBackground(const SplashScreen());
          case login:
            return const LoginScreen();
          case signup:
            return const SignupScreen();
          case home:
            return _withBackground(const HomeScreen());
          case products:
            return _withBackground(const ProductListScreen());
          case productDetail:
            return _withBackground(const ProductDetailScreen());
          case cart:
            return _withBackground(const CartScreen());
          case wishlist:
            return _withBackground(const WishlistScreen());
          case orders:
            return _withBackground(const OrderScreen());
          case orderTracking:
            return _withBackground(const OrderTrackingScreen());
          case profile:
            return _withBackground(const ProfileScreen());
          case landing:
            return _withBackground(const LandingPage());
          case admin:
            return _withBackground(const AdminDashboardScreen());
          default:
            return _withBackground(const HomeScreen());
        }
      },
    );
  }

  static Widget _withBackground(Widget child) {
    return AppBackground(child: child);
  }
}
