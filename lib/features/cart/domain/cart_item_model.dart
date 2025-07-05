// lib/features/cart/domain/cart_item_model.dart

import 'package:preloft_app/features/product/domain/product_model.dart';

/// ## Cart Item Model
///
/// Merepresentasikan satu item unik di dalam keranjang belanja.
///
/// Model ini berisi informasi kuantitas dan data lengkap produk
/// yang bersangkutan untuk memudahkan tampilan di UI.
class CartItem {

  CartItem({
    required this.id,
    required this.quantity,
    required this.product,
  });
  /// ID unik untuk item di dalam keranjang (bisa sama dengan product.id).
  final String id;
  
  /// Jumlah produk ini di dalam keranjang.
  final int quantity;

  /// Data lengkap dari produk yang ditambahkan ke keranjang.
  final ProductModel product;

  /// Menghitung total harga untuk item ini (harga produk x kuantitas).
  double get totalPrice => product.price * quantity;

  /// Membuat salinan CartItem dengan beberapa nilai yang diperbarui.
  /// Berguna untuk mengubah kuantitas.
  CartItem copyWith({
    int? quantity,
    ProductModel? product,
  }) {
    return CartItem(
      id: id,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }
}
