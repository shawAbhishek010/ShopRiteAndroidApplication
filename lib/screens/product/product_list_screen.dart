import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/cart_micro_interactions.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final CartMicroInteractionController _cartAnimationController;

  @override
  void initState() {
    super.initState();
    _cartAnimationController = CartMicroInteractionController();
  }

  @override
  void dispose() {
    _cartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.visibleFilteredProducts;
    final totalProducts = provider.filteredProducts.length;
    final selectedCategory = provider.selectedCategory;
    return CartAnimationScope(
      controller: _cartAnimationController,
      child: Scaffold(
        appBar: AppBar(
          title: Text(selectedCategory ?? 'Discover'),
          actions: [
            if (selectedCategory != null)
              TextButton(
                onPressed: () =>
                    context.read<ProductProvider>().selectCategory(null),
                child: const Text('All'),
              ),
            PremiumCartAction(controller: _cartAnimationController),
          ],
        ),
        body: switch (provider.state) {
          ViewState.loading => const LoadingWidget(
            message: 'Loading products...',
          ),
          ViewState.error => AppErrorWidget(
            message: provider.errorMessage ?? 'No products found.',
            onRetry: provider.loadProducts,
          ),
          _ => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  onChanged: provider.updateSearch,
                  onSubmitted: (_) => provider.submitSearch(),
                  decoration: InputDecoration(
                    hintText: selectedCategory == null
                        ? 'Search fashion, bags, shoes...'
                        : 'Search in $selectedCategory',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              if (selectedCategory != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text('$selectedCategory collection'),
                      onDeleted: () =>
                          context.read<ProductProvider>().selectCategory(null),
                    ),
                  ),
                ),
              Expanded(
                child: totalProducts == 0
                    ? const AppErrorWidget(
                        message: 'No products match your filters.',
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid.builder(
                              itemCount: products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 230,
                                    childAspectRatio: 0.68,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemBuilder: (context, index) {
                                return ProductCard(product: products[index]);
                              },
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: Column(
                                children: [
                                  Text(
                                    'Showing ${products.length} of $totalProducts products',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 10),
                                  if (provider.canLoadMore)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: provider.loadMoreProducts,
                                        icon: const Icon(Icons.expand_more),
                                        label: Text(
                                          'More (${provider.remainingProductCount} left)',
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        },
      ),
    );
  }
}
