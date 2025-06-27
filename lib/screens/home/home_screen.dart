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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLocation = '';

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
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => AppNavigator.goToProfile(context),
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
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
                    const SizedBox(height: 12),
                    // Location Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Semua Lokasi'),
                            selected: _selectedLocation.isEmpty,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedLocation = '');
                            },
                          ),
                          const SizedBox(width: 8),
                          ...['Jakarta', 'Bandung', 'Surabaya', 'Yogyakarta', 'Medan']
                              .map((location) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(location),
                                      selected: _selectedLocation == location,
                                      onSelected: (selected) {
                                        setState(() => _selectedLocation = selected ? location : '');
                                      },
                                    ),
                                  )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Products List
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    List<ProductModel> filteredProducts = products;

                    // Apply search filter
                    if (_searchQuery.isNotEmpty) {
                      filteredProducts = products
                          .where((product) =>
                              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              product.description.toLowerCase().contains(_searchQuery.toLowerCase()))
                          .toList();
                    }

                    // Apply location filter
                    if (_selectedLocation.isNotEmpty) {
                      filteredProducts = filteredProducts
                          .where((product) => product.location == _selectedLocation)
                          .toList();
                    }

                    if (filteredProducts.isEmpty) {
                      return EmptyStateWidget(
                        title: _searchQuery.isNotEmpty || _selectedLocation.isNotEmpty
                            ? 'Tidak ada produk ditemukan'
                            : 'Belum ada produk',
                        message: _searchQuery.isNotEmpty || _selectedLocation.isNotEmpty
                            ? 'Coba ubah kata kunci atau filter pencarian'
                            : 'Belum ada produk yang dijual',
                        icon: Icons.search_off,
                        onRefresh: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedLocation = '';
                          });
                        },
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(product: product);
                      },
                    );
                  },
                  loading: () => const LoadingWidget(message: 'Memuat produk...'),
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
        loading: () => const LoadingWidget(message: 'Memuat data pengguna...'),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      floatingActionButton: currentUserAsync.when(
        data: (user) {
          if (user?.role == UserRole.penjual) {
            return FloatingActionButton(
              onPressed: () => AppNavigator.goToAddProduct(context),
              child: const Icon(Icons.add),
            );
          }
          return null;
        },
        loading: () => null,
        error: (_, __) => null,
      ),
      bottomNavigationBar: currentUserAsync.when(
        data: (user) => _buildBottomNavBar(context, user),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget? _buildBottomNavBar(BuildContext context, UserModel? user) {
    if (user == null) return null;

    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
    ];

    List<VoidCallback> onTapCallbacks = [
      () {}, // Home - already here
    ];

    if (user.role == UserRole.penjual) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.inventory),
        label: 'Produk Saya',
      ));
      onTapCallbacks.add(() => AppNavigator.goToMyProducts(context));
    }

    if (user.role == UserRole.admin) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Dashboard',
      ));
      onTapCallbacks.add(() => AppNavigator.goToAdminDashboard(context));
    }

    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ));
    onTapCallbacks.add(() => AppNavigator.goToProfile(context));

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) => onTapCallbacks[index](),
      items: items,
    );
  }
}