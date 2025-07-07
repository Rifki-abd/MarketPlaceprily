// lib/features/checkout/data/checkout_repository.dart

import 'package:preloft_app/features/cart/domain/cart_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutRepository {
  final SupabaseClient _client;
  CheckoutRepository(this._client);

  /// Membuat pesanan dari item keranjang menggunakan fungsi RPC di Supabase.
  /// Ini memastikan semua operasi (membuat order, membuat order_items)
  /// terjadi dalam satu transaksi yang aman.
  Future<String> createOrderFromCart(List<CartItem> cartItems, double totalPrice, String userId) async {
    try {
      // Ubah daftar CartItem menjadi format JSON yang bisa dikirim ke Supabase
      final itemsJson = cartItems.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price_per_item': item.product.price,
      }).toList();

      // Panggil fungsi RPC
      final orderId = await _client.rpc('create_order_from_cart', params: {
        'p_user_id': userId,
        'p_total_price': totalPrice,
        'p_items': itemsJson,
      });

      return orderId as String;

    } catch (e) {
      throw Exception('Gagal membuat pesanan: $e');
    }
  }
}
