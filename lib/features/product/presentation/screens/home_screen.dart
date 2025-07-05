// lib/features/product/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:preloft_app/features/product/presentation/providers/product_provider.dart';
import 'package:preloft_app/features/product/presentation/widgets/product_card.dart';
import 'package:preloft_app/shared/widgets/empty_state_widget.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsStreamProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preloft'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Keranjang',
                // PASTIKAN INI MENGGUNAKAN PUSH
                onPressed: () => context.push('/cart'),
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
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return EmptyStateWidget(
              title: 'Belum Ada Produk',
              message: 'Jadilah yang pertama untuk menjual barang di sini!',
              icon: Icons.storefront,
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
            icon: Icons.error_outline,
            onRefresh: () => ref.invalidate(allProductsStreamProvider),
          ),
        ),
      ),
      floatingActionButton: userProfile?.role == UserRole.penjual
          ? FloatingActionButton(
              onPressed: () => context.push('/add-product'),
              tooltip: 'Tambah Produk',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}