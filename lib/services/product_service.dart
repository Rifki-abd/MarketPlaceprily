import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

final productServiceProvider = Provider.autoDispose((ref) => ProductService());

final allProductsProvider = StreamProvider.autoDispose<List<ProductModel>>((ref) {
  return Supabase.instance.client
      .from('products')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) => data.map(ProductModel.fromMap).toList());
});

final myProductsProvider = StreamProvider.autoDispose.family<List<ProductModel>, String>((ref, sellerId) {
  return Supabase.instance.client
      .from('products')
      .stream(primaryKey: ['id'])
      .eq('seller_id', sellerId)
      .order('created_at', ascending: false)
      .map((data) => data.map(ProductModel.fromMap).toList());
});

class ProductService {
  final _supabase = Supabase.instance.client;

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _supabase.from('products').insert(data);
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _supabase.from('products').update(data).eq('id', productId);
  }

  Future<void> deleteProduct(String productId) async {
    await _supabase.from('products').delete().eq('id', productId);
  }

  Future<ProductModel?> getProductById(String productId) async {
    final data = await _supabase.from('products').select().eq('id', productId).single();
    return ProductModel.fromMap(data);
  }
}
