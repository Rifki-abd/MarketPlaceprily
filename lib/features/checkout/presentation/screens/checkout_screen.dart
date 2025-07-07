// lib/features/checkout/presentation/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:preloft_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:preloft_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Dengarkan perubahan pada checkoutNotifier
    ref.listen<AsyncValue<String?>>(checkoutNotifierProvider, (_, state) {
      state.when(
        data: (orderId) {
          if (orderId != null) {
            // Jika ada orderId, navigasi ke halaman sukses
            context.go('/order-success/$orderId');
          }
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
          );
        },
        loading: () {}, // Tidak perlu melakukan apa-apa saat loading
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Pesanan'),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: item.product.imageUrl != null 
                  ? NetworkImage(item.product.imageUrl!) 
                  : null,
            ),
            title: Text(item.product.name),
            subtitle: Text('${item.quantity} x ${currencyFormatter.format(item.product.price)}'),
            trailing: Text(currencyFormatter.format(item.quantity * item.product.price)),
          );
        },
      ),
      bottomNavigationBar: _buildCheckoutBottomBar(context, ref, currencyFormatter, totalPrice),
    );
  }

  Widget _buildCheckoutBottomBar(BuildContext context, WidgetRef ref, NumberFormat formatter, double price) {
    final checkoutState = ref.watch(checkoutNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran:', style: TextStyle(fontSize: 16)),
              Text(
                formatter.format(price),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: checkoutState.isLoading 
              ? null 
              : () => ref.read(checkoutNotifierProvider.notifier).placeOrder(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: checkoutState.isLoading
              ? const LoadingWidget(message: 'Memproses...')
              : const Text('Bayar Sekarang'),
          ),
        ],
      ),
    );
  }
}
