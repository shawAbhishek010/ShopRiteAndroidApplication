import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/helpers.dart';
import '../../models/product_model.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/animated_add_to_cart_button.dart';
import '../../widgets/cart_micro_interactions.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GlobalKey _imageKey = GlobalKey();
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
    final product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product not found.')));
    }
    final wishlist = context.watch<WishlistProvider>();
    final isSaved = wishlist.contains(product.id);
    return CartAnimationScope(
      controller: _cartAnimationController,
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name),
          actions: [
            PremiumCartAction(controller: _cartAnimationController),
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
                              _ProductImage(
                                product: product,
                                width: 320,
                                imageKey: _imageKey,
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                child: _ProductDetails(
                                  product: product,
                                  imageKey: _imageKey,
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
                                  imageKey: _imageKey,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _ProductDetails(
                                product: product,
                                imageKey: _imageKey,
                                isSaved: isSaved,
                                onWishlistToggle: () =>
                                    wishlist.toggle(product),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.product,
    required this.width,
    required this.imageKey,
  });

  final ProductModel product;
  final double width;
  final GlobalKey imageKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: imageKey,
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
    required this.imageKey,
    required this.isSaved,
    required this.onWishlistToggle,
  });

  final ProductModel product;
  final GlobalKey imageKey;
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
              child: AnimatedAddToCartButton(
                product: product,
                sourceKey: imageKey,
                idleLabel: 'Add to cart',
                icon: Icons.shopping_bag_outlined,
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
