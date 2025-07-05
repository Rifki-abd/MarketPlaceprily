// lib/features/cart/presentation/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/features/cart/domain/cart_item_model.dart';
import 'package:preloft_app/features/product/domain/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(ProductModel product) {
    final itemIndex = state.indexWhere((item) => item.product.id == product.id);

    if (itemIndex != -1) {
      final existingItem = state[itemIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + 1);
      
      final newState = List<CartItem>.from(state);
      newState[itemIndex] = updatedItem;
      state = newState;
    } else {
      final newItem = CartItem(id: product.id, quantity: 1, product: product);
      state = [...state, newItem];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void decreaseQuantity(String productId) {
    final itemIndex = state.indexWhere((item) => item.product.id == productId);
    if (itemIndex == -1) return;

    final existingItem = state[itemIndex];
    if (existingItem.quantity > 1) {
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity - 1);
      final newState = List<CartItem>.from(state);
      newState[itemIndex] = updatedItem;
      state = newState;
    } else {
      removeItem(productId);
    }
  }
  
  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final AutoDisposeProvider<double> cartTotalPriceProvider = Provider.autoDispose<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
});

final AutoDisposeProvider<int> cartItemCountProvider = Provider.autoDispose<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (sum, item) => sum + item.quantity);
});