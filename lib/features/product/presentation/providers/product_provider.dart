// lib/features/product/presentation/providers/product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketplace_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:marketplace_app/features/product/data/product_repository.dart';
import 'package:marketplace_app/features/product/domain/product_model.dart';
import 'package:marketplace_app/core/providers/supabase_provider.dart';

// 1. Provider untuk Repository
final AutoDisposeProvider<ProductRepository> productRepositoryProvider = Provider.autoDispose<ProductRepository>((ref) {
  return ProductRepository(ref.watch(supabaseClientProvider));
});


// 2. Provider untuk STREAM semua produk (data real-time)
final AutoDisposeStreamProvider<List<ProductModel>> allProductsStreamProvider = StreamProvider.autoDispose<List<ProductModel>>((ref) {
  final productRepo = ref.watch(productRepositoryProvider);
  return productRepo.getAllProductsStream();
});


// 3. Provider untuk produk milik user yang sedang login (SELLER)
// Ini adalah data turunan (derived state) dari stream semua produk.
final AutoDisposeProvider<List<ProductModel>> myProductsProvider = Provider.autoDispose<List<ProductModel>>((ref) {
  final productsAsyncValue = ref.watch(allProductsStreamProvider);
  final userId = ref.watch(authProvider).value?.id;

  return productsAsyncValue.when(
    data: (products) {
      if (userId == null) return [];
      return products.where((p) => p.sellerId == userId).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});


// 4. Provider untuk mengambil satu produk berdasarkan ID.
// Berguna untuk halaman detail produk.
final AutoDisposeProviderFamily<ProductModel?, String> productByIdProvider = Provider.autoDispose.family<ProductModel?, String>((ref, productId) {
  final productsAsyncValue = ref.watch(allProductsStreamProvider);
  return productsAsyncValue.whenData((products) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (_) {
      // Mengembalikan null jika produk tidak ditemukan.
      return null;
    }
  }).value;
});


// 5. Provider Notifier untuk Aksi (Create, Update, Delete)
// Ini mengelola state loading/error untuk operasi yang memiliki efek samping.
final AutoDisposeStateNotifierProvider<ProductActionNotifier, AsyncValue<void>> productActionNotifierProvider =
    StateNotifierProvider.autoDispose<ProductActionNotifier, AsyncValue<void>>((ref) {
  return ProductActionNotifier(ref.watch(productRepositoryProvider), ref);
});

class ProductActionNotifier extends StateNotifier<AsyncValue<void>> {

  ProductActionNotifier(this._repository, this._ref) : super(const AsyncData(null));
  final ProductRepository _repository;
  final Ref _ref;

  Future<bool> runAction(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      // Invalidate stream provider agar UI merefleksikan perubahan data.
      _ref.invalidate(allProductsStreamProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data) {
    return runAction(() => _repository.createProduct(data));
  }

  Future<bool> updateProduct(String productId, Map<String, dynamic> data) {
    return runAction(() => _repository.updateProduct(productId, data));
  }
  
  Future<bool> deleteProduct(String productId) {
    return runAction(() => _repository.deleteProduct(productId));
  }
}
