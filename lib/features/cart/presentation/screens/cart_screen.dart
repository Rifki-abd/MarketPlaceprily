// lib/features/cart/presentation/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marketplace_app/shared/widgets/empty_state_widget.dart';
import 'package:marketplace_app/features/cart/presentation/providers/cart_provider.dart';

/// ## Cart Screen
///
/// Layar yang menampilkan semua item di dalam keranjang belanja.
/// UI ini sepenuhnya reaktif terhadap perubahan state dari `cartProvider`.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearCartDialog(context, ref),
              tooltip: 'Kosongkan Keranjang',
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? const EmptyStateWidget(
              title: 'Keranjang Kosong',
              message: 'Cari produk menarik dan tambahkan ke keranjang Anda!',
              icon: Icons.shopping_cart_outlined,
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(item.product.name.substring(0, 1)),
                  ),
                  title: Text(item.product.name),
                  subtitle: Text(currencyFormatter.format(item.product.price)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => ref.read(cartProvider.notifier).decreaseQuantity(item.id),
                      ),
                      Text(item.quantity.toString(), style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => ref.read(cartProvider.notifier).addProduct(item.product),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildCheckoutBar(context, currencyFormatter, totalPrice),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, NumberFormat formatter, double price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Harga:', style: TextStyle(color: Colors.grey)),
              Text(
                formatter.format(price),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement checkout logic
            },
            icon: const Icon(Icons.payment),
            label: const Text('Checkout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showClearCartDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Anda yakin ingin mengosongkan seluruh keranjang?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Kosongkan'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(cartProvider.notifier).clearCart();
    }
  }
}
