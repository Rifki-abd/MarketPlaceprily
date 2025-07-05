// lib/features/product/presentation/screens/my_products_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/product/domain/product_model.dart';
import 'package:preloft_app/features/product/presentation/providers/product_provider.dart';
import 'package:preloft_app/features/product/presentation/widgets/product_card.dart';
import 'package:preloft_app/shared/widgets/empty_state_widget.dart';

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
      body: RefreshIndicator( // Tambahkan RefreshIndicator di sini
        onRefresh: () async => ref.invalidate(allProductsStreamProvider),
        child: myProducts.isEmpty
            ? Stack( // Gunakan Stack agar bisa di-scroll untuk refresh
                children: [
                  ListView(), // Widget yang bisa di-scroll
                  const EmptyStateWidget( // PERBAIKAN: Menambahkan 'const'
                    title: 'Belum Ada Produk',
                    message: 'Anda belum menambahkan produk untuk dijual.',
                    icon: Icons.inventory_2,
                    // onRefresh tidak lagi diperlukan di sini
                  ),
                ],
              )
            : ListView.builder(
                itemCount: myProducts.length,
                itemBuilder: (context, index) {
                  final product = myProducts[index];
                  return ProductCard(
                    product: product,
                    showActions: true,
                    // Gunakan push untuk navigasi yang lebih baik
                    onEdit: () => context.push('/edit-product/${product.id}'),
                    onDelete: () => _showDeleteDialog(context, ref, product),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
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
      final success = await ref.read(productActionNotifierProvider.notifier).deleteProduct(product.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${product.name}" berhasil dihapus.'), backgroundColor: Colors.green),
        );
      }
    }
  }
}