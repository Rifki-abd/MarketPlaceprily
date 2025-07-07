// lib/features/product/data/product_repository.dart

import 'dart:typed_data'; // Diperlukan untuk Uint8List
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:preloft_app/features/product/domain/product_model.dart';

class ProductRepository {
  ProductRepository(this._client);
  final SupabaseClient _client;

  /// Mengunggah gambar produk menggunakan kontennya (bytes).
  Future<String> uploadProductImage({
    required Uint8List imageBytes,
    required String fileName,
    required String productId,
  }) async {
    try {
      final imageExtension = fileName.split('.').last.toLowerCase();
      
      // --- PERBAIKAN DI SINI ---
      // Mengoreksi ekstensi 'jpg' menjadi 'jpeg' untuk tipe MIME yang valid.
      final mimeTypeExtension = imageExtension == 'jpg' ? 'jpeg' : imageExtension;
      
      final uploadPath = '/$productId/product.$imageExtension';

      await _client.storage.from('product-images').uploadBinary(
            uploadPath,
            imageBytes,
            fileOptions: FileOptions(
              // Gunakan tipe MIME yang sudah dikoreksi
              contentType: 'image/$mimeTypeExtension',
              upsert: true,
            ),
          );
      
      return _client.storage.from('product-images').getPublicUrl(uploadPath);
    } catch (e) {
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  // Fungsi lain tidak berubah
  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      await _client.from('products').insert(data);
    } catch (e) {
      throw Exception('Gagal membuat produk: $e');
    }
  }
  
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
