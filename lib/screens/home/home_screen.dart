import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../landing/widgets/footer_widget.dart';
import '../product/widgets/product_card.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_grid.dart';
import 'widgets/recommendation_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = context.watch<ProductProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopRite'),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.wishlist),
            icon: const Icon(Icons.favorite_border),
          ),
          Badge(
            label: Text('${cart.itemCount}'),
            isLabelVisible: cart.itemCount > 0,
            child: IconButton(
              tooltip: 'Cart',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
          if (context.watch<AuthProvider>().isAdmin)
            IconButton(
              tooltip: 'Admin',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.admin),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          IconButton(
            tooltip: themeProvider.isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: context.read<ThemeProvider>().toggleTheme,
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.58),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => products.loadProducts(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!products.isOnline || products.errorMessage != null)
                _OfflineNotice(
                  message: products.errorMessage ?? 'You are offline.',
                ),
              const BannerCarousel(),
              const SizedBox(height: 24),
              TextField(
                onChanged: products.updateSearch,
                onSubmitted: (_) {
                  products.submitSearch();
                  Navigator.pushNamed(context, AppRoutes.products);
                },
                decoration: const InputDecoration(
                  hintText: 'Search sneakers, bags, dresses...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              if (products.searchQuery.isNotEmpty) ...[
                _SearchResultsSection(products: products),
                const SizedBox(height: 24),
              ],
              const CategoryGrid(),
              const SizedBox(height: 24),
              const RecommendationSection(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending now',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.products),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.trendingProducts.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 230,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: products.trendingProducts[index]);
                },
              ),
              const SizedBox(height: 26),
              const FooterWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultsSection extends StatelessWidget {
  const _SearchResultsSection({required this.products});

  final ProductProvider products;

  @override
  Widget build(BuildContext context) {
    final results = products.homeSearchResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                results.isEmpty
                    ? 'No matches for "${products.searchQuery}"'
                    : 'Search results for "${products.searchQuery}"',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (results.isNotEmpty)
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.products),
                child: const Text('More'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (results.isEmpty)
          const Text('Try shoes, bags, dresses, jackets, socks or accessories.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 230,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return ProductCard(product: results[index], enableHero: false);
            },
          ),
      ],
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}
