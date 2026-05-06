import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  static const _imageSets = [
    [
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=700&auto=format&fit=crop',
    ],
    [
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1548126032-079a0fb0099d?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1523398002811-999ca8dec234?w=700&auto=format&fit=crop',
    ],
    [
      'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1583846717393-dc2412c95ed7?w=700&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1524498250077-390f9e378fc0?w=700&auto=format&fit=crop',
    ],
  ];

  Timer? _timer;
  int _currentSet = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted) return;
      setState(() {
        _currentSet = (_currentSet + 1) % _imageSets.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 380;
        final isMedium = width >= 650;
        final height = width >= 1000 ? 460.0 : (isMedium ? 390.0 : 350.0);
        final contentPadding = isCompact ? 18.0 : 24.0;
        final titleStyle = TextStyle(
          color: Colors.white,
          fontSize: isCompact ? 38 : 44,
          height: 1.04,
          fontWeight: FontWeight.w900,
        );
        final subtitleStyle = TextStyle(
          color: Colors.white,
          fontSize: isCompact ? 16 : 18,
          height: 1.32,
          fontWeight: FontWeight.w500,
        );
        final titleGap = isCompact ? 10.0 : 14.0;
        final buttonGap = isCompact ? 18.0 : 24.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 650),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _ShoppingImageWall(
                    key: ValueKey('wall-$_currentSet'),
                    images: _imageSets[_currentSet],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.15,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.42),
                        Colors.black.withValues(alpha: 0.28),
                        Colors.black.withValues(alpha: 0.82),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Shop the season in one place',
                            textAlign: TextAlign.center,
                            style: titleStyle,
                          ),
                          SizedBox(height: titleGap),
                          Text(
                            'Curated shoes, bags, dresses, jackets and accessories with fresh deals every day.',
                            textAlign: TextAlign.center,
                            style: subtitleStyle,
                          ),
                          SizedBox(height: buttonGap),
                          FilledButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.products,
                            ),
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: const Text('Start Shopping'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShoppingImageWall extends StatelessWidget {
  const _ShoppingImageWall({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 6
            : constraints.maxWidth >= 760
            ? 5
            : 3;
        final tileCount = columns * 4;

        return Transform.rotate(
          angle: -0.055,
          child: OverflowBox(
            maxWidth: constraints.maxWidth * 1.18,
            maxHeight: constraints.maxHeight * 1.26,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tileCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 0.74,
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
