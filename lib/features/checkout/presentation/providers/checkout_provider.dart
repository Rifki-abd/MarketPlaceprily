// lib/features/checkout/presentation/providers/checkout_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:preloft_app/features/checkout/data/checkout_repository.dart';

// Provider untuk CheckoutRepository
final checkoutRepositoryProvider = Provider.autoDispose<CheckoutRepository>((ref) {
  return CheckoutRepository(ref.watch(supabaseClientProvider));
});

// Notifier untuk Aksi Checkout
final checkoutNotifierProvider = 
    StateNotifierProvider.autoDispose<CheckoutNotifier, AsyncValue<String?>>((ref) {
  return CheckoutNotifier(ref);
});

class CheckoutNotifier extends StateNotifier<AsyncValue<String?>> {
  CheckoutNotifier(this._ref) : super(const AsyncData(null));
  final Ref _ref;

  Future<void> placeOrder() async {
    state = const AsyncLoading();
    try {
      final cartItems = _ref.read(cartProvider);
      final totalPrice = _ref.read(cartTotalPriceProvider);
      final userId = _ref.read(supabaseClientProvider).auth.currentUser?.id;

      if (userId == null || cartItems.isEmpty) {
        throw Exception('User tidak login atau keranjang kosong.');
      }

      // Memanggil repository untuk membuat pesanan
      final orderId = await _ref.read(checkoutRepositoryProvider)
          .createOrderFromCart(cartItems, totalPrice, userId);

      // Jika berhasil, bersihkan keranjang dan set state ke sukses dengan ID pesanan
      _ref.read(cartProvider.notifier).clearCart();
      state = AsyncData(orderId);
      
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
