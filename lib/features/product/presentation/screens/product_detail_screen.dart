// lib/features/product/presentation/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketplace_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';
import 'package:marketplace_app/features/product/domain/product_model.dart'; // FIX: Path impor diperbaiki
import 'package:marketplace_app/features/product/presentation/providers/product_provider.dart';

/// ## Product Detail Screen
/// Menampilkan detail lengkap dari satu produk.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: Watch stream provider utama untuk mendapatkan AsyncValue
    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
      ),
      // FIX: Gunakan .when pada AsyncValue, bukan pada ProductModel?
      body: productAsync == null
          ? const Center(child: LoadingWidget(message: 'Memuat produk...'))
          : _buildProductDetails(context, ref, productAsync),
    );
  }

  Widget _buildProductDetails(BuildContext context, WidgetRef ref, ProductModel product) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(product.description),
              ],
            ),
          ),
        ),
        _buildBottomBar(context, ref, product),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -4)),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          ref.read(cartProvider.notifier).addProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} ditambahkan ke keranjang.'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Tambah ke Keranjang'),
      ),
    );
  }
}
