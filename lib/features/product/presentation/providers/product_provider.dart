// lib/features/product/presentation/providers/product_provider.dart

import 'dart:typed_data'; // Diperlukan untuk Uint8List
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/product/data/product_repository.dart';
import 'package:preloft_app/features/product/domain/product_model.dart';
import 'package:uuid/uuid.dart';

// (Provider lain tidak berubah)
final AutoDisposeProvider<ProductRepository> productRepositoryProvider = Provider.autoDispose<ProductRepository>((ref) {
  return ProductRepository(ref.watch(supabaseClientProvider));
});

final AutoDisposeStreamProvider<List<ProductModel>> allProductsStreamProvider = StreamProvider.autoDispose<List<ProductModel>>((ref) {
  final productRepo = ref.watch(productRepositoryProvider);
  return productRepo.getAllProductsStream();
});

final AutoDisposeProvider<List<ProductModel>> myProductsProvider = Provider.autoDispose<List<ProductModel>>((ref) {
  final productsAsyncValue = ref.watch(allProductsStreamProvider);
  final userId = ref.watch(authStateChangesProvider).value?.id;
  return productsAsyncValue.when(
    data: (products) => products.where((p) => p.sellerId == userId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final AutoDisposeProviderFamily<ProductModel?, String> productByIdProvider = Provider.autoDispose.family<ProductModel?, String>((ref, productId) {
  final productsAsyncValue = ref.watch(allProductsStreamProvider);
  return productsAsyncValue.whenData((products) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }).value;
});

// Provider Notifier
final AutoDisposeStateNotifierProvider<ProductActionNotifier, AsyncValue<void>> productActionNotifierProvider =
    StateNotifierProvider.autoDispose<ProductActionNotifier, AsyncValue<void>>((ref) {
  return ProductActionNotifier(ref.watch(productRepositoryProvider), ref);
});

class ProductActionNotifier extends StateNotifier<AsyncValue<void>> {
  ProductActionNotifier(this._repository, this._ref) : super(const AsyncData(null));
  final ProductRepository _repository;
  final Ref _ref;

  // --- PERBAIKAN DI SINI ---
  // Menerima data produk, konten gambar (bytes), dan nama file
  Future<bool> createProduct(Map<String, dynamic> data, Uint8List imageBytes, String fileName) async {
    state = const AsyncLoading();
    try {
      final productId = const Uuid().v4();
      
      // Upload gambar menggunakan bytes dan nama file
      final imageUrl = await _repository.uploadProductImage(
        imageBytes: imageBytes,
        fileName: fileName,
        productId: productId,
      );

      data['id'] = productId;
      data['image_url'] = imageUrl;

      await _repository.createProduct(data);
      
      _ref.invalidate(allProductsStreamProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // (Fungsi lain tidak berubah)
  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repository.updateProduct(productId, data);
      _ref.invalidate(allProductsStreamProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
  
  Future<bool> deleteProduct(String productId) async {
     state = const AsyncLoading();
    try {
      await _repository.deleteProduct(productId);
      _ref.invalidate(allProductsStreamProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
