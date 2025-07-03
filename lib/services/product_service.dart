// lib/services/product_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

final productServiceProvider = Provider<ProductService>((ref) => ProductService());

// Tetap pertahankan allProductsProvider untuk mengambil semua data sebagai stream
final allProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return Supabase.instance.client
      .from('products')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((List<Map<String, dynamic>> data) =>
          data.map((json) => ProductModel.fromMap(json)).toList());
});

final myProductsProvider = StreamProvider.family<List<ProductModel>, String>((ref, sellerId) {
  return Supabase.instance.client
      .from('products')
      .stream(primaryKey: ['id'])
      .eq('seller_id', sellerId)
      .order('created_at', ascending: false)
      .map((List<Map<String, dynamic>> data) =>
          data.map((json) => ProductModel.fromMap(json)).toList());
});

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProductModel> createProduct({
    required UserModel seller,
    required String name,
    required double price,
    required String description,
    required String location,
    required String waNumber,
  }) async {
    try {
      final Map<String, dynamic> productData = {
        'seller_id': seller.id,
        'seller_name': seller.name,
        'name': name,
        'price': price,
        'description': description,
        'location': location,
        'image_url': null,
        'wa_number': waNumber,
      };

      final Map<String, dynamic> response = await _supabase
          .from('products')
          .insert(productData)
          .select()
          .single();

      return ProductModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  Future<void> updateProduct({
    required String productId,
    String? name,
    double? price,
    String? description,
    String? location,
    String? waNumber,
    String? imageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (name != null) updates['name'] = name;
      if (price != null) updates['price'] = price;
      if (description != null) updates['description'] = description;
      if (location != null) updates['location'] = location;
      if (waNumber != null) updates['wa_number'] = waNumber;
      if (imageUrl != null) updates['image_url'] = imageUrl;

      if (updates.isNotEmpty) {
        await _supabase
            .from('products')
            .update(updates)
            .eq('id', productId);
      }
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .limit(1);

      if (data.isNotEmpty) {
        return ProductModel.fromMap(data.first);
      }
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
    return null;
  }

  // >>>>>> PERUBAHAN DI SINI UNTUK CLIENT-SIDE FILTERING <<<<<<
  Stream<List<ProductModel>> searchProducts(String query) {
    // Ambil stream dari semua produk
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          if (query.isEmpty) {
            return data.map((json) => ProductModel.fromMap(json)).toList();
          }

          final lowerCaseQuery = query.toLowerCase();
          return data
              .map((json) => ProductModel.fromMap(json)) // Konversi dulu ke ProductModel
              .where((product) {
                // Lakukan filtering OR di sisi klien
                return product.name.toLowerCase().contains(lowerCaseQuery) ||
                       product.description.toLowerCase().contains(lowerCaseQuery) ||
                       product.location.toLowerCase().contains(lowerCaseQuery);
              })
              .toList();
        });
  }
  // >>>>>> AKHIR PERUBAHAN <<<<<<

  Stream<List<ProductModel>> getProductsByLocation(String location) {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('location', location)
        .order('created_at', ascending: false)
        .map((List<Map<String, dynamic>> data) =>
            data.map((json) => ProductModel.fromMap(json)).toList());
  }
}