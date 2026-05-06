import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';

class CartMicroInteractionController extends ChangeNotifier {
  final GlobalKey cartTargetKey = GlobalKey();

  void pulseCart() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  void flyProductToCart({
    required BuildContext context,
    required GlobalKey sourceKey,
    required String imageUrl,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    final sourceBox =
        sourceKey.currentContext?.findRenderObject() as RenderBox?;
    final targetBox =
        cartTargetKey.currentContext?.findRenderObject() as RenderBox?;

    if (overlay == null ||
        overlayBox == null ||
        sourceBox == null ||
        targetBox == null ||
        !sourceBox.hasSize ||
        !targetBox.hasSize) {
      pulseCart();
      return;
    }

    final sourceTopLeft = overlayBox.globalToLocal(
      sourceBox.localToGlobal(Offset.zero),
    );
    final targetTopLeft = overlayBox.globalToLocal(
      targetBox.localToGlobal(Offset.zero),
    );
    final sourceRect = sourceTopLeft & sourceBox.size;
    final targetRect = targetTopLeft & targetBox.size;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingCartImage(
        imageUrl: imageUrl,
        sourceRect: sourceRect,
        targetRect: targetRect,
        onComplete: entry.remove,
      ),
    );

    overlay.insert(entry);
    Future<void>.delayed(const Duration(milliseconds: 430), pulseCart);
  }
}

class CartAnimationScope extends InheritedWidget {
  const CartAnimationScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final CartMicroInteractionController controller;

  static CartMicroInteractionController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CartAnimationScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(CartAnimationScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

class PremiumCartAction extends StatefulWidget {
  const PremiumCartAction({super.key, required this.controller});

  final CartMicroInteractionController controller;

  @override
  State<PremiumCartAction> createState() => _PremiumCartActionState();
}

class _PremiumCartActionState extends State<PremiumCartAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int? _lastCount;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    widget.controller.addListener(_playPulse);
  }

  @override
  void didUpdateWidget(covariant PremiumCartAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_playPulse);
    widget.controller.addListener(_playPulse);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_playPulse);
    _pulseController.dispose();
    super.dispose();
  }

  void _playPulse() {
    if (!mounted) return;
    _pulseController.forward(from: 0);
  }

  void _playAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _playPulse());
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider?>();
    final count = cart?.itemCount ?? 0;
    if (_lastCount == null) {
      _lastCount = count;
    } else if (count > _lastCount!) {
      _lastCount = count;
      _playAfterBuild();
    } else {
      _lastCount = count;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final value = _pulseController.value;
        final shake = math.sin(value * math.pi * 6) * 3.4 * (1 - value);
        final lift = -math.sin(value * math.pi) * 2.4;
        final scale = 1 + (math.sin(value * math.pi) * 0.13);
        final rotation = math.sin(value * math.pi * 4) * 0.045 * (1 - value);

        return Transform.translate(
          offset: Offset(shake, lift),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: SizedBox(
        key: widget.controller.cartTargetKey,
        width: 48,
        height: 48,
        child: Center(
          child: Badge(
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Text('$count', key: ValueKey(count)),
            ),
            isLabelVisible: count > 0,
            child: IconButton(
              tooltip: 'Cart',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlyingCartImage extends StatefulWidget {
  const _FlyingCartImage({
    required this.imageUrl,
    required this.sourceRect,
    required this.targetRect,
    required this.onComplete,
  });

  final String imageUrl;
  final Rect sourceRect;
  final Rect targetRect;
  final VoidCallback onComplete;

  @override
  State<_FlyingCartImage> createState() => _FlyingCartImageState();
}

class _FlyingCartImageState extends State<_FlyingCartImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _quadraticBezier(Offset start, Offset control, Offset end, double t) {
    final inverse = 1 - t;
    return Offset(
      (inverse * inverse * start.dx) +
          (2 * inverse * t * control.dx) +
          (t * t * end.dx),
      (inverse * inverse * start.dy) +
          (2 * inverse * t * control.dy) +
          (t * t * end.dy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = widget.sourceRect.width.clamp(56.0, 84.0);
    final ratio = widget.sourceRect.height / widget.sourceRect.width;
    final imageHeight = (imageWidth * ratio).clamp(62.0, 104.0);

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final curved = Curves.easeInOutCubic.transform(_controller.value);
            final start = widget.sourceRect.center;
            final end = widget.targetRect.center;
            final midpoint = Offset(
              lerpDouble(start.dx, end.dx, 0.52)!,
              math.min(start.dy, end.dy) - 92,
            );
            final center = _quadraticBezier(start, midpoint, end, curved);
            final scale = lerpDouble(1, 0.28, Curves.easeIn.transform(curved))!;
            final fadeStart = 0.78;
            final opacity = curved < fadeStart
                ? 1.0
                : (1 - ((curved - fadeStart) / (1 - fadeStart))).clamp(
                    0.0,
                    1.0,
                  );

            return Transform.translate(
              offset: Offset(
                center.dx - ((imageWidth * scale) / 2),
                center.dy - ((imageHeight * scale) / 2),
              ),
              child: Transform.scale(
                alignment: Alignment.topLeft,
                scale: scale,
                child: Opacity(opacity: opacity, child: child),
              ),
            );
          },
          child: SizedBox(
            width: imageWidth,
            height: imageHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 180,
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: Color(0xFF2A2023),
                    child: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
