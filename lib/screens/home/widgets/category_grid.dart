import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/product_provider.dart';
import '../../../routes/app_routes.dart';
import 'category_card.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const _categoryImages = {
    'Accessories':
        'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=700&auto=format&fit=crop',
    'Bags':
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=700&auto=format&fit=crop',
    'Dresses':
        'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=700&auto=format&fit=crop',
    'Jackets':
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=700&auto=format&fit=crop',
    'Shoes':
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=700&auto=format&fit=crop',
    'Socks':
        'https://images.unsplash.com/photo-1586350977771-b3b0abd50c82?w=700&auto=format&fit=crop',
  };

  IconData _iconFor(String category) {
    return switch (category) {
      'Shoes' => Icons.directions_run,
      'Bags' => Icons.work_outline,
      'Dresses' => Icons.checkroom,
      'Accessories' => Icons.watch_outlined,
      'Socks' => Icons.layers_outlined,
      _ => Icons.category_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final categories = provider.categories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        childAspectRatio: 1.35,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          label: category,
          icon: _iconFor(category),
          imageUrl: _categoryImages[category],
          isSelected: provider.selectedCategory == category,
          onTap: () {
            context.read<ProductProvider>().selectCategory(category);
            Navigator.pushNamed(context, AppRoutes.products);
          },
        );
      },
    );
  }
}
