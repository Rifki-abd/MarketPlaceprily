// lib/features/product/presentation/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:preloft_app/features/chat/data/chat_repository.dart';
import 'package:preloft_app/features/product/domain/product_model.dart';
import 'package:preloft_app/features/product/presentation/providers/product_provider.dart';
import 'package:preloft_app/shared/widgets/empty_state_widget.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});
  final String productId;

  Future<void> _launchWhatsApp(BuildContext context, String waNumber) async {
    final number = waNumber.startsWith('62') ? waNumber : '62${waNumber.substring(1)}';
    final url = Uri.parse('https://wa.me/$number');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka WhatsApp')),
        );
      }
    }
  }

  // Fungsi untuk memulai chat
  Future<void> _startChat(BuildContext context, WidgetRef ref, ProductModel product) async {
    final currentUser = ref.read(supabaseClientProvider).auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk memulai chat')),
      );
      return;
    }

    // Mencegah penjual chat dengan diri sendiri
    if (currentUser.id == product.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda tidak bisa chat untuk produk Anda sendiri')),
      );
      return;
    }

    try {
      final chatRepository = ChatRepository(ref.read(supabaseClientProvider));
      final chatRoomId = await chatRepository.startOrGetChatRoom(
        buyerId: currentUser.id,
        sellerId: product.sellerId,
        productId: product.id,
      );
      
      // Navigasi ke layar chat
      if (context.mounted) {
        context.push('/chat/$chatRoomId');
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProductsAsync = ref.watch(allProductsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
      ),
      body: allProductsAsync.when(
        data: (products) {
          ProductModel? product;
          try {
            product = products.firstWhere((p) => p.id == productId);
          } catch (e) {
            product = null;
          }

          if (product == null) {
            return const EmptyStateWidget(
              title: 'Produk Tidak Ditemukan',
              message: 'Produk yang Anda cari mungkin telah dihapus atau tidak tersedia.',
              icon: Icons.search_off,
            );
          }
          return _buildProductDetails(context, ref, product);
        },
        loading: () => const Center(child: LoadingWidget(message: 'Memuat produk...')),
        error: (err, stack) => Center(
          child: EmptyStateWidget(
            title: 'Gagal Memuat Produk',
            message: err.toString(),
            icon: Icons.error_outline,
            onRefresh: () => ref.invalidate(allProductsStreamProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, WidgetRef ref, ProductModel product) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (UI Detail Produk lainnya tetap sama)
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: LoadingWidget());
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                          )
                        : const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(product.price),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(height: 32),
                Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(product.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                const Divider(height: 32),
                Text('Informasi Penjual', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.store)),
                  title: Text(product.sellerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(product.location),
                  trailing: IconButton(
                    icon: Icon(Icons.message, color: Colors.green.shade700),
                    onPressed: () => _launchWhatsApp(context, product.waNumber),
                    tooltip: 'Hubungi via WhatsApp',
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomBar(context, ref, product),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () => _startChat(context, ref, product),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: const Icon(Icons.chat_bubble_outline),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(cartProvider.notifier).addProduct(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} ditambahkan ke keranjang.'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Lihat',
                      onPressed: () => context.push('/cart'),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Tambah ke Keranjang'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
