import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../utils/app_router.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Saya'),
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          
          final myProductsAsync = ref.watch(myProductsProvider(user.id));
          
          return myProductsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return EmptyStateWidget(
                  title: 'Belum ada produk',
                  message: 'Anda belum menambahkan produk apapun.\nMulai jual produk pertama Anda!',
                  icon: Icons.inventory_2,
                  onRefresh: () => ref.refresh(myProductsProvider(user.id)),
                );
              }

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    showActions: true,
                    onEdit: () => AppNavigator.goToEditProduct(context, product.id),
                    onDelete: () => _showDeleteDialog(context, ref, product),
                  );
                },
              );
            },
            loading: () => const LoadingWidget(message: 'Memuat produk Anda...'),
            error: (error, stack) => EmptyStateWidget(
              title: 'Gagal memuat produk',
              message: error.toString(),
              icon: Icons.error,
              onRefresh: () => ref.refresh(myProductsProvider(user.id)),
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Memuat data pengguna...'),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppNavigator.goToAddProduct(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, currentUserAsync.value),
    );
  }

  Widget? _buildBottomNavBar(BuildContext context, UserModel? user) {
    if (user == null) return null;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      onTap: (index) {
        switch (index) {
          case 0:
            AppNavigator.goToHome(context);
            break;
          case 1:
            // Already here
            break;
          case 2:
            AppNavigator.goToProfile(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Produk Saya',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(productServiceProvider).deleteProduct(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus produk: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
