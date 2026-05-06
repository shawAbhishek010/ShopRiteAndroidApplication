import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'cart_micro_interactions.dart';

class AnimatedAddToCartButton extends StatefulWidget {
  const AnimatedAddToCartButton({
    super.key,
    required this.product,
    required this.sourceKey,
    this.idleLabel = 'Add',
    this.addedLabel = 'Added',
    this.soldOutLabel = 'Sold out',
    this.icon = Icons.add_shopping_cart,
  });

  final ProductModel product;
  final GlobalKey sourceKey;
  final String idleLabel;
  final String addedLabel;
  final String soldOutLabel;
  final IconData icon;

  @override
  State<AnimatedAddToCartButton> createState() =>
      _AnimatedAddToCartButtonState();
}

class _AnimatedAddToCartButtonState extends State<AnimatedAddToCartButton> {
  static const _pressDuration = Duration(milliseconds: 90);
  static const _successDuration = Duration(milliseconds: 920);

  bool _isPressed = false;
  bool _isAdded = false;
  bool _isBusy = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<bool> _addProduct(BuildContext context) async {
    final cartProvider = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final beforeCount = cartProvider.itemCount;

    await cartProvider.addProduct(widget.product);
    await Future<void>.delayed(Duration.zero);

    if (!context.mounted) return false;

    final message = cartProvider.message;
    final didAdd = message == null || cartProvider.itemCount > beforeCount;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          didAdd ? '${widget.product.name} added to cart' : message,
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );

    if (didAdd) {
      unawaited(
        productProvider.trackAddToCart(widget.product).catchError((_) {}),
      );
    } else {
      cartProvider.clearMessage();
    }

    return didAdd;
  }

  Future<void> _handleTap() async {
    if (_isBusy || !widget.product.isInStock) return;

    final currentContext = context;
    setState(() {
      _isBusy = true;
      _isPressed = true;
    });
    HapticFeedback.selectionClick();
    await Future<void>.delayed(_pressDuration);

    if (mounted) {
      setState(() => _isPressed = false);
    }

    if (!currentContext.mounted) return;
    final cartAnimation = CartAnimationScope.maybeOf(currentContext);
    final didAdd = await _addProduct(currentContext);
    if (!currentContext.mounted) return;

    if (didAdd) {
      HapticFeedback.lightImpact();
      cartAnimation?.flyProductToCart(
        context: currentContext,
        sourceKey: widget.sourceKey,
        imageUrl: widget.product.imageUrl,
      );
      setState(() => _isAdded = true);
      _resetTimer?.cancel();
      _resetTimer = Timer(_successDuration, () {
        if (!mounted) return;
        setState(() {
          _isAdded = false;
          _isBusy = false;
        });
      });
    } else {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = widget.product.isInStock && !_isBusy;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = widget.product.isInStock
        ? (_isAdded ? AppColors.success : colorScheme.primary)
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = widget.product.isInStock
        ? Colors.white
        : colorScheme.onSurfaceVariant;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : (_isAdded ? 1.025 : 1),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isAdded
                ? Colors.white.withValues(alpha: isDark ? 0.16 : 0.24)
                : Colors.transparent,
          ),
          boxShadow: [
            if (_isAdded)
              BoxShadow(
                color: AppColors.success.withValues(alpha: isDark ? 0.28 : 0.2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? _handleTap : null,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 190),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: _ButtonContent(
                  key: ValueKey(
                    '${widget.product.isInStock}-$_isAdded-$_isBusy',
                  ),
                  icon: _isAdded ? Icons.check_rounded : widget.icon,
                  label: widget.product.isInStock
                      ? (_isAdded
                            ? '${widget.addedLabel} \u2713'
                            : widget.idleLabel)
                      : widget.soldOutLabel,
                  color: foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
