import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _ratingController = TextEditingController(text: '4.5');
  final _stockController = TextEditingController(text: '10');
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProductModel? _editingProduct;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _ratingController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final product = ProductModel(
      id: _editingProduct?.id ?? _makeProductId(_nameController.text),
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      discount: double.parse(_discountController.text.trim()),
      rating: double.parse(_ratingController.text.trim()).clamp(0, 5),
      imageUrl: _imageUrlController.text.trim(),
      stock: int.parse(_stockController.text.trim()),
      description: _descriptionController.text.trim(),
      views: _editingProduct?.views ?? 0,
      addToCartCount: _editingProduct?.addToCartCount ?? 0,
    );

    final products = context.read<ProductProvider>();
    if (_editingProduct == null) {
      await products.createProduct(product);
    } else {
      await products.updateProduct(product);
    }

    if (!mounted) return;
    _clearForm();
    setState(() => _isSaving = false);
    messenger.showSnackBar(
      SnackBar(content: Text('${product.name} saved successfully')),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Remove ${product.name} from the catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<ProductProvider>().deleteProduct(product.id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${product.name} deleted')));
    }
  }

  void _editProduct(ProductModel product) {
    setState(() {
      _editingProduct = product;
      _nameController.text = product.name;
      _categoryController.text = product.category;
      _priceController.text = product.price.toStringAsFixed(0);
      _discountController.text = product.discount.toStringAsFixed(0);
      _ratingController.text = product.rating.toStringAsFixed(1);
      _stockController.text = product.stock.toString();
      _imageUrlController.text = product.imageUrl;
      _descriptionController.text = product.description;
    });
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _categoryController.clear();
    _priceController.clear();
    _discountController.text = '0';
    _ratingController.text = '4.5';
    _stockController.text = '10';
    _imageUrlController.clear();
    _descriptionController.clear();
    _editingProduct = null;
  }

  String _makeProductId(String name) {
    final slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return '$slug-${DateTime.now().millisecondsSinceEpoch}';
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  String? _number(String? value) {
    if (_required(value) != null) return 'Required';
    return double.tryParse(value!.trim()) == null ? 'Enter a number' : null;
  }

  String? _wholeNumber(String? value) {
    if (_required(value) != null) return 'Required';
    return int.tryParse(value!.trim()) == null ? 'Enter a whole number' : null;
  }

  void _returnToStore() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>().products;

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(child: Text('Admin access required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to store',
          onPressed: _returnToStore,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Store home',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            ),
            icon: const Icon(Icons.storefront_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Orders and analytics'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _editingProduct == null ? 'Create product' : 'Edit product',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Wrap(
              runSpacing: 12,
              spacing: 12,
              children: [
                _Field(
                  controller: _nameController,
                  label: 'Product name',
                  validator: _required,
                ),
                _Field(
                  controller: _categoryController,
                  label: 'Category',
                  validator: _required,
                ),
                _Field(
                  controller: _priceController,
                  label: 'Price',
                  keyboardType: TextInputType.number,
                  validator: _number,
                ),
                _Field(
                  controller: _discountController,
                  label: 'Discount %',
                  keyboardType: TextInputType.number,
                  validator: _number,
                ),
                _Field(
                  controller: _ratingController,
                  label: 'Rating',
                  keyboardType: TextInputType.number,
                  validator: _number,
                ),
                _Field(
                  controller: _stockController,
                  label: 'Stock',
                  keyboardType: TextInputType.number,
                  validator: _wholeNumber,
                ),
                _Field(
                  controller: _imageUrlController,
                  label: 'Image URL',
                  validator: _required,
                  wide: true,
                ),
                _Field(
                  controller: _descriptionController,
                  label: 'Description',
                  validator: _required,
                  wide: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveProduct,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save product'),
                ),
              ),
              if (_editingProduct != null) ...[
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => setState(() => _clearForm()),
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Text('Catalog', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...products.map(
            (product) => Card(
              child: ListTile(
                title: Text(product.name),
                subtitle: Text(
                  '${product.category}  |  Stock: ${product.stock}  |  Rs ${product.price.toStringAsFixed(0)}',
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () => _editProduct(product),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _deleteProduct(product),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.wide = false,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? 620 : 300,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
