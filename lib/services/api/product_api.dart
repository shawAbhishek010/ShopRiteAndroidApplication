import '../../models/product_model.dart';

class ProductApi {
  static const _productsPerCategory = 20;

  Future<List<ProductModel>> fetchProducts() async {
    return [
      ..._buildCategory(
        category: 'Shoes',
        slug: 'shoe',
        names: const [
          'Street Form Sneakers',
          'Blush Runner Shoes',
          'Court Lite Sneakers',
          'Pulse Knit Trainers',
          'Airline Chunky Sneakers',
          'Rose Walk Trainers',
          'Studio Lace-Up Shoes',
          'City Sole Sneakers',
        ],
        imageUrls: _shoes,
        basePrice: 2499,
      ),
      ..._buildCategory(
        category: 'Bags',
        slug: 'bag',
        names: const [
          'Metro Sling Bag',
          'Rose Tote Carryall',
          'Mini Chain Shoulder Bag',
          'Weekend Canvas Backpack',
          'Soft Hobo Bag',
          'Studio Satchel',
          'Pearl Mini Bag',
          'Travel Edit Backpack',
        ],
        imageUrls: _bags,
        basePrice: 1599,
      ),
      ..._buildCategory(
        category: 'Dresses',
        slug: 'dress',
        names: const [
          'Noor Linen Dress',
          'Coral Wrap Dress',
          'Evening Satin Slip',
          'Petal Day Dress',
          'Rose Midi Dress',
          'Studio Shirt Dress',
          'Weekend Maxi Dress',
          'Blush Party Dress',
        ],
        imageUrls: _dresses,
        basePrice: 2199,
      ),
      ..._buildCategory(
        category: 'Jackets',
        slug: 'jacket',
        names: const [
          'Arc Denim Overshirt',
          'Ruby Bomber Jacket',
          'City Trench Layer',
          'Soft Suede Shacket',
          'Cropped Moto Jacket',
          'Weekend Puffer',
          'Tailored Utility Jacket',
          'Blush Varsity Jacket',
        ],
        imageUrls: _jackets,
        basePrice: 2999,
      ),
      ..._buildCategory(
        category: 'Socks',
        slug: 'sock',
        names: const [
          'Cloud Rib Socks',
          'Pastel Crew Socks',
          'Athletic Cushion Socks',
          'Pattern Pop Socks',
          'Sneaker Liner Socks',
          'Soft Lounge Socks',
          'Retro Stripe Socks',
          'Daily Cotton Socks',
        ],
        imageUrls: _socks,
        basePrice: 299,
      ),
      ..._buildCategory(
        category: 'Accessories',
        slug: 'accessory',
        names: const [
          'Cedar Minimal Watch',
          'Pearl Layer Necklace',
          'Tinted Sun Frames',
          'Silk Blush Scarf',
          'Gold Hoop Earrings',
          'Rose Hair Claw',
          'Minimal Belt',
          'Stack Charm Bracelet',
        ],
        imageUrls: _accessories,
        basePrice: 699,
      ),
    ];
  }

  List<ProductModel> _buildCategory({
    required String category,
    required String slug,
    required List<String> names,
    required List<String> imageUrls,
    required int basePrice,
  }) {
    return List<ProductModel>.generate(_productsPerCategory, (index) {
      final number = index + 1;
      final name = names[index % names.length];
      final price = basePrice + ((index % 9) * 230) + ((index ~/ 8) * 95);
      final discount = 8 + (index % 23);
      final rating = 4.0 + ((index % 9) * 0.1);
      final stock = 8 + ((index * 7) % 84);
      final views = 50 + ((index * 17) % 180);
      final cartAdds = 12 + ((index * 11) % 70);

      return ProductModel(
        id: '$slug-${number.toString().padLeft(2, '0')}',
        name: number <= names.length ? name : '$name ${_variantName(index)}',
        category: category,
        price: price.toDouble(),
        discount: discount.toDouble(),
        rating: rating.clamp(4.0, 4.9),
        imageUrl: imageUrls[index % imageUrls.length],
        stock: stock,
        description:
            'Curated $category pick with a polished fashion-store finish and everyday wearability.',
        views: views,
        addToCartCount: cartAdds,
      );
    });
  }

  String _variantName(int index) {
    const variants = [
      'Edit',
      'Drop',
      'Studio',
      'Select',
      'Capsule',
      'Reserve',
      'Mode',
    ];
    return variants[index % variants.length];
  }

static const _shoes = [
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=900&auto=format&fit=crop',
  ];

  static const _bags = [
    'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1594223274512-ad4803739b7c?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524498250077-390f9e378fc0?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1605733160314-4fc7dac4bb16?w=900&auto=format&fit=crop',
  ];

  static const _dresses = [
    'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=900&auto=format&fit=crop',
  ];

  static const _jackets = [
    'https://images.unsplash.com/photo-1523398002811-999ca8dec234?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1543076447-215ad9ba6923?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1548126032-079a0fb0099d?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1548883354-7622d03aca27?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=900&auto=format&fit=crop',
  ];

  static const _socks = [
    'https://images.unsplash.com/photo-1586350977771-b3b0abd50c82?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1582966772680-860e372bb558?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1586350977770-4d5c37156db1?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1618354691551-44de113f0164?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=900&auto=format&fit=crop',
  ];

  static const _accessories = [
    'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1583846717393-dc2412c95ed7?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1506629905607-d9c297d95d8b?w=900&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?w=900&auto=format&fit=crop',
  ];
}
