import 'package:flutter/material.dart';

class BrandSection extends StatelessWidget {
  const BrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Featured brands', style: TextStyle(fontSize: 18)),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text('FreshFarm')),
            Chip(label: Text('BakeHouse')),
            Chip(label: Text('PureDairy')),
          ],
        ),
      ],
    );
  }
}
