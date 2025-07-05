// lib/features/cart/presentation/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketplace_app/features/product/domain/product_model.dart';
import 'package:marketplace_app/features/cart/domain/cart_item_model.dart';

/// ## Cart Notifier
///
/// StateNotifier yang mengelola daftar [CartItem] (keranjang belanja).
/// Untuk saat ini, implementasi ini menyimpan keranjang di memori (in-memory).
///
/// Bertindak sebagai "single source of truth" untuk semua data keranjang.
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]); // State awal adalah list kosong

  /// Menambahkan produk ke keranjang.
  ///
  /// Jika produk sudah ada, kuantitasnya akan ditambah.
  /// Jika belum, item baru akan dibuat.
  void addProduct(ProductModel product) {
    // Cek apakah produk sudah ada di keranjang
    final itemIndex = state.indexWhere((item) => item.product.id == product.id);

    if (itemIndex != -1) {
      // Produk sudah ada, update kuantitasnya
      final existingItem = state[itemIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + 1);
      
      final newState = List<CartItem>.from(state);
      newState[itemIndex] = updatedItem;
      state = newState;
    } else {
      // Produk belum ada, tambahkan item baru
      final newItem = CartItem(id: product.id, quantity: 1, product: product);
      state = [...state, newItem];
    }
  }

  /// Menghapus satu item dari keranjang.
  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// Mengurangi kuantitas produk. Jika kuantitas menjadi nol, item akan dihapus.
  void decreaseQuantity(String productId) {
    final itemIndex = state.indexWhere((item) => item.product.id == productId);
    if (itemIndex == -1) return; // Item tidak ditemukan

    final existingItem = state[itemIndex];
    if (existingItem.quantity > 1) {
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity - 1);
      final newState = List<CartItem>.from(state);
      newState[itemIndex] = updatedItem;
      state = newState;
    } else {
      // Jika kuantitas hanya 1, hapus item
      removeItem(productId);
    }
  }
  
  /// Mengosongkan seluruh keranjang.
  void clearCart() {
    state = [];
  }
}

/// ## Cart Provider
/// Provider utama untuk mengakses [CartNotifier] dari UI.
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// ## Cart Total Price Provider
///
/// Provider turunan (derived state) yang secara otomatis menghitung
/// total harga dari semua item di keranjang.
/// UI hanya perlu me-watch provider ini untuk mendapatkan total harga terbaru.
final AutoDisposeProvider<double> cartTotalPriceProvider = Provider.autoDispose<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  var totalPrice = 0;
  for (final item in cartItems) {
    totalPrice += item.totalPrice;
  }
  return totalPrice;
});

/// ## Cart Item Count Provider
/// Provider turunan untuk menghitung jumlah total item di keranjang.
final AutoDisposeProvider<int> cartItemCountProvider = Provider.autoDispose<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.length;
});
