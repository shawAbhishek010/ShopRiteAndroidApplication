import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/helpers.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product not found.')));
    }
    final wishlist = context.watch<WishlistProvider>();
    final isSaved = wishlist.contains(product.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            tooltip: isSaved ? 'Remove wishlist' : 'Save',
            onPressed: () => wishlist.toggle(product),
            icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProductImage(product: product, width: 320),
                            const SizedBox(width: 28),
                            Expanded(
                              child: _ProductDetails(
                                product: product,
                                isSaved: isSaved,
                                onWishlistToggle: () =>
                                    wishlist.toggle(product),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: _ProductImage(
                                product: product,
                                width: 260,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _ProductDetails(
                              product: product,
                              isSaved: isSaved,
                              onWishlistToggle: () => wishlist.toggle(product),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, required this.width});

  final ProductModel product;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Hero(
          tag: 'product-${product.id}',
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 500,
              placeholder: (_, _) => const _ImagePlaceholder(),
              errorWidget: (_, _, _) => const _ImagePlaceholder(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({
    required this.product,
    required this.isSaved,
    required this.onWishlistToggle,
  });

  final ProductModel product;
  final bool isSaved;
  final VoidCallback onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              label: Text(product.category),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              avatar: const Icon(Icons.star, color: Colors.amber, size: 18),
              label: Text(product.rating.toStringAsFixed(1)),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(product.isInStock ? 'In stock' : 'Sold out'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(product.description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              Helpers.formatCurrency(product.salePrice),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (product.discount > 0)
              Text(
                '${product.discount.toStringAsFixed(0)}% off',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: product.isInStock
                    ? () async {
                        final cartProvider = context.read<CartProvider>();
                        final productProvider = context.read<ProductProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        await cartProvider.addProduct(product);
                        await productProvider.trackAddToCart(product);
                        if (context.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Add to cart'),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.outlined(
              tooltip: isSaved ? 'Remove wishlist' : 'Save',
              onPressed: onWishlistToggle,
              icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
