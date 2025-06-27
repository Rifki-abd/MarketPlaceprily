import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../utils/app_router.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user?.role != UserRole.admin) {
            return const Center(
              child: Text('Akses ditolak. Hanya admin yang dapat mengakses halaman ini.'),
            );
          }

          return Column(
            children: [
              // Statistics Card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: productsAsync.when(
                    data: (products) => _buildStatistics(products),
                    loading: () => const LoadingWidget(),
                    error: (error, stack) => Text('Error loading stats: $error'),
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk untuk moderasi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Products List
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    List<ProductModel> filteredProducts = products;

                    if (_searchQuery.isNotEmpty) {
                      filteredProducts = products
                          .where((product) =>
                              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              product.sellerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              product.description.toLowerCase().contains(_searchQuery.toLowerCase()))
                          .toList();
                    }

                    if (filteredProducts.isEmpty) {
                      return EmptyStateWidget(
                        title: _searchQuery.isNotEmpty
                            ? 'Tidak ada produk ditemukan'
                            : 'Belum ada produk',
                        message: _searchQuery.isNotEmpty
                            ? 'Coba ubah kata kunci pencarian'
                            : 'Belum ada produk yang perlu dimoderasi',
                        icon: Icons.search_off,
                        onRefresh: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildAdminProductCard(context, product);
                      },
                    );
                  },
                  loading: () => const LoadingWidget(message: 'Memuat semua produk...'),
                  error: (error, stack) => EmptyStateWidget(
                    title: 'Gagal memuat produk',
                    message: error.toString(),
                    icon: Icons.error,
                    onRefresh: () => ref.refresh(allProductsProvider),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Memuat data admin...'),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, currentUserAsync.value),
    );
  }

  Widget _buildStatistics(List<ProductModel> products) {
    final totalProducts = products.length;
    final sellersCount = products.map((p) => p.sellerId).toSet().length;
    final totalValue = products.fold<double>(0, (sum, product) => sum + product.price);
    
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      children: [
        const Text(
          'Statistik Marketplace',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Produk',
                totalProducts.toString(),
                Icons.inventory,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Penjual Aktif',
                sellersCount.toString(),
                Icons.store,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          'Total Nilai Produk',
          currencyFormatter.format(totalValue),
          Icons.attach_money,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProductCard(BuildContext context, ProductModel product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            product.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penjual: ${product.sellerName}'),
            Text('Lokasi: ${product.location}'),
            Text('Dibuat: ${DateFormat('dd/MM/yyyy').format(product.createdAt)}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Lihat Detail'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus Produk'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'view') {
              AppNavigator.goToProductDetail(context, product.id);
            } else if (value == 'delete') {
              _showDeleteDialog(context, ref, product);
            }
          },
        ),
        onTap: () => AppNavigator.goToProductDetail(context, product.id),
      ),
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
          icon: Icon(Icons.admin_panel_settings),
          label: 'Dashboard',
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus produk "${product.name}"?'),
            const SizedBox(height: 8),
            Text('Penjual: ${product.sellerName}'),
            const SizedBox(height: 8),
            const Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
            SnackBar(
              content: Text('Produk "${product.name}" berhasil dihapus'),
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