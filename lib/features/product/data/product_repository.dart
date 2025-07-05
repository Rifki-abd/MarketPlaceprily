// lib/features/product/data/product_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marketplace_app/features/product/domain/product_model.dart';

/// ## Product Repository
///
/// Bertanggung jawab untuk operasi CRUD (Create, Read, Update, Delete)
/// terkait produk dengan Supabase.
/// Layer ini mengisolasi logika akses data dari sisa aplikasi.
class ProductRepository {
  ProductRepository(this._client);
  final SupabaseClient _client;

  /// Mengambil semua produk dari database.
  /// Menggunakan stream untuk data real-time.
  Stream<List<ProductModel>> getAllProductsStream() {
    try {
      return _client
          .from('products')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((data) => data.map(ProductModel.fromMap).toList());
    } catch (e) {
      // Mengubah error menjadi stream error untuk ditangani oleh provider
      return Stream.error(Exception('Gagal mengambil data produk: $e'));
    }
  }

  /// Menambah produk baru ke database.
  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      await _client.from('products').insert(data);
    } catch (e) {
      throw Exception('Gagal membuat produk: $e');
    }
  }

  /// Memperbarui produk yang ada di database.
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _client.from('products').update(data).eq('id', productId);
    } catch (e) {
      throw Exception('Gagal memperbarui produk: $e');
    }
  }

  /// Menghapus produk dari database.
  Future<void> deleteProduct(String productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }
}
