import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../routes/app_routes.dart';
import '../../state/order_provider.dart';

class ProfileScreen extends riverpod.ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final orders = ref.watch(
      userOrdersProvider(
        OrderListRequest(userId: auth.user?.userId, isAdmin: auth.isAdmin),
      ),
    );
    final name = auth.user?.name ?? 'ShopRite Guest';
    final orderCount = orders.maybeWhen(
      data: (orders) => orders.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 34,
            child: Text(name.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(name, style: Theme.of(context).textTheme.titleLarge),
          ),
          Center(child: Text(auth.user?.email ?? 'Login to sync your data')),
          const SizedBox(height: 20),
          Row(
            children: [
              _Metric(label: 'Cart', value: '${cart.itemCount}'),
              _Metric(
                label: 'Wishlist',
                value: '${wishlist.wishlistIds.length}',
              ),
              _Metric(label: 'Orders', value: '$orderCount'),
            ],
          ),
          const SizedBox(height: 20),
          if (auth.isAdmin)
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Orders and analytics'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
            )
          else
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('My orders'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
            ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Wishlist'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.wishlist),
          ),
          if (auth.isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Admin dashboard'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
