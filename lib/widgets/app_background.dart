import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.overlay = AppBackgroundOverlay.soft,
  });

  final Widget child;
  final AppBackgroundOverlay overlay;

  static const _images = [
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1523398002811-999ca8dec234?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1548126032-079a0fb0099d?w=700&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=700&auto=format&fit=crop',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _ImageWall(images: _images),
        _BackgroundOverlay(style: overlay),
        child,
      ],
    );
  }
}

enum AppBackgroundOverlay { soft, dark }

class _BackgroundOverlay extends StatelessWidget {
  const _BackgroundOverlay({required this.style});

  final AppBackgroundOverlay style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (style == AppBackgroundOverlay.dark) {
      return Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.1,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.30),
                  Colors.black.withValues(alpha: 0.34),
                  Colors.black.withValues(alpha: 0.82),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.78),
            colorScheme.primary.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.86),
          ],
        ),
      ),
    );
  }
}

class _ImageWall extends StatelessWidget {
  const _ImageWall({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 7
            : constraints.maxWidth >= 760
            ? 5
            : 3;
        final tileCount = columns * 5;

        return Transform.rotate(
          angle: -0.06,
          child: OverflowBox(
            maxWidth: constraints.maxWidth * 1.16,
            maxHeight: constraints.maxHeight * 1.24,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tileCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: images[index % images.length],
                    fit: BoxFit.cover,
                    memCacheWidth: 520,
                    placeholder: (_, _) => ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.24),
                    ),
                    errorWidget: (_, _, _) => ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.35),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
