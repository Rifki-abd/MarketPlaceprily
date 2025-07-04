import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../utils/app_router.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go(context),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => products.isEmpty
            ? EmptyStateWidget(
                title: 'Belum ada produk',
                message: 'Jadilah yang pertama menjual produk di sini!',
                icon: Icons.storefront,
                onRefresh: () => ref.refresh(allProductsProvider),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(allProductsProvider),
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(product: products[index]),
                ),
              ),
        loading: () => const LoadingWidget(message: 'Memuat produk...'),
        error: (error, _) => EmptyStateWidget(
          title: 'Gagal memuat produk',
          message: error.toString(),
          icon: Icons.error,
          onRefresh: () => ref.refresh(allProductsProvider),
        ),
      ),
      floatingActionButton: user?.role == UserRole.penjual
          ? FloatingActionButton(
              onPressed: () => context.go(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
