// lib/features/product/data/product_repository.dart

import 'dart:io';

import 'package:preloft_app/features/product/domain/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  ProductRepository(this._client);
  final SupabaseClient _client;

  // Fungsi untuk upload gambar (Tidak berubah)
  Future<String> uploadProductImage({
    required File image,
    required String productId,
  }) async {
    try {
      final imageExtension = image.path.split('.').last.toLowerCase();
      final imagePath = '/$productId/product.$imageExtension';
      
      await _client.storage.from('product-images').upload(imagePath, image);
      return _client.storage.from('product-images').getPublicUrl(imagePath);
    } catch (e) {
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  // Fungsi untuk menyimpan data produk ke database
  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      await _client.from('products').insert(data);
    } catch (e) {
      throw Exception('Gagal membuat produk: $e');
    }
  }

  // --- Sisa kode tidak berubah ---

  Stream<List<ProductModel>> getAllProductsStream() {
    try {
      return _client
          .from('products')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((data) => data.map(ProductModel.fromMap).toList());
    } catch (e) {
      return Stream.error(Exception('Gagal mengambil data produk: $e'));
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _client.from('products').update(data).eq('id', productId);
    } catch (e) {
      throw Exception('Gagal memperbarui produk: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }
}