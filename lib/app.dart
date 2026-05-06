import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_riverpod/misc.dart' as riverpod_misc;
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';
import 'routes/app_routes.dart';

class ShopRiteApp extends StatelessWidget {
  const ShopRiteApp({super.key, this.overrides = const []});

  final List<riverpod_misc.Override> overrides;

  @override
  Widget build(BuildContext context) {
    return riverpod.ProviderScope(
      overrides: overrides,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(
            create: (_) => ProductProvider()..loadProducts(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
            create: (_) => CartProvider(),
            update: (_, auth, cart) => cart!..bindUser(auth.user?.userId),
          ),
          ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
            create: (_) => WishlistProvider(),
            update: (_, auth, wishlist) =>
                wishlist!..bindUser(auth.user?.userId),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRoutes.onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}
