// lib/features/product/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/features/auth/domain/user_model.dart';
import 'package:marketplace_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:marketplace_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:marketplace_app/shared/widgets/empty_state_widget.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';
import 'package:marketplace_app/features/product/presentation/providers/product_provider.dart';
import 'package:marketplace_app/features/product/presentation/widgets/product_card.dart';

/// ## Home Screen
/// Layar utama yang menampilkan daftar semua produk yang tersedia.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsStreamProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          // Tombol Keranjang
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => context.go('/cart'),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Tombol Profil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return EmptyStateWidget(
              title: 'Belum Ada Produk',
              message: 'Jadilah yang pertama untuk menjual barang di sini!',
              icon: Icons.storefront, // FIX: Menambahkan ikon yang hilang
              onRefresh: () => ref.invalidate(allProductsStreamProvider),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allProductsStreamProvider),
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) => ProductCard(product: products[index]),
            ),
          );
        },
        loading: () => const Center(child: LoadingWidget(message: 'Memuat produk...')),
        error: (err, stack) => Center(
          child: EmptyStateWidget(
            title: 'Oops, Terjadi Kesalahan',
            message: err.toString(),
            icon: Icons.error_outline, // FIX: Menambahkan ikon yang hilang
            onRefresh: () => ref.invalidate(allProductsStreamProvider),
          ),
        ),
      ),
      floatingActionButton: userProfile?.role == UserRole.penjual
          ? FloatingActionButton(
              onPressed: () => context.go('/add-product'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
