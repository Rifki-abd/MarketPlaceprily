// lib/features/product/presentation/screens/my_products_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/features/product/domain/product_model.dart';
import 'package:marketplace_app/shared/widgets/empty_state_widget.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';
import 'package:marketplace_app/features/product/presentation/providers/product_provider.dart';
import 'package:marketplace_app/features/product/presentation/widgets/product_card.dart';

/// ## My Products Screen
///
/// Menampilkan daftar produk yang dimiliki oleh user (penjual) yang sedang login.
class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider ini secara otomatis memfilter produk berdasarkan user ID
    final myProducts = ref.watch(myProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Saya'),
      ),
      body: myProducts.isEmpty
          ? EmptyStateWidget(
              title: 'Belum Ada Produk',
              message: 'Anda belum menambahkan produk untuk dijual.',
              icon: Icons.inventory_2,
              onRefresh: () => ref.invalidate(allProductsStreamProvider),
            )
          : ListView.builder(
              itemCount: myProducts.length,
              itemBuilder: (context, index) {
                final product = myProducts[index];
                return ProductCard(
                  product: product,
                  showActions: true,
                  onEdit: () => context.go('/edit-product/${product.id}'),
                  onDelete: () => _showDeleteDialog(context, ref, product),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-product'),
        tooltip: 'Tambah Produk',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(productActionNotifierProvider.notifier).deleteProduct(product.id);
    }
  }
}
