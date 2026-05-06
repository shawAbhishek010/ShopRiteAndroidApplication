import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/helpers.dart';
import '../../../models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/animated_add_to_cart_button.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, this.enableHero = true});

  final ProductModel product;
  final bool enableHero;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final isSaved = wishlist.contains(widget.product.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.read<ProductProvider>().trackProductView(widget.product);
          Navigator.pushNamed(
            context,
            AppRoutes.productDetail,
            arguments: widget.product,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                key: _imageKey,
                fit: StackFit.expand,
                children: [
                  HeroMode(
                    enabled: widget.enableHero,
                    child: Hero(
                      tag: 'product-${widget.product.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 700,
                        placeholder: (_, _) => const _ImagePlaceholder(),
                        errorWidget: (_, _, _) => const _ImagePlaceholder(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        tooltip: isSaved ? 'Remove wishlist' : 'Save',
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? Colors.redAccent : Colors.black87,
                        ),
                        onPressed: () => wishlist.toggle(widget.product),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.category,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Helpers.formatCurrency(widget.product.salePrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (widget.product.discount > 0)
                        Flexible(
                          child: Text(
                            '${widget.product.discount.toStringAsFixed(0)}% off',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedAddToCartButton(
                      product: widget.product,
                      sourceKey: _imageKey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondary.withValues(alpha: 0.55),
            colorScheme.primary.withValues(alpha: 0.12),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: colorScheme.primary.withValues(alpha: 0.65),
          size: 34,
        ),
      ),
    );
  }
}
