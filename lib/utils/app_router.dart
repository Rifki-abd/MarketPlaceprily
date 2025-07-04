import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/add_product_screen.dart';
import '../screens/product/edit_product_screen.dart';
import '../screens/seller/my_products_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplashing = state.matchedLocation == '/splash';
      if (isSplashing) return null;

      if (!isLoggedIn) return '/login';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/product/:id', builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!)),
      GoRoute(path: '/add-product', builder: (context, state) => const AddProductScreen()),
      GoRoute(path: '/edit-product/:id', builder: (context, state) => EditProductScreen(productId: state.pathParameters['id']!)),
      GoRoute(path: '/my-products', builder: (context, state) => const MyProductsScreen()),
      GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
  );
});

// Memastikan AppNavigator tetap ada
class AppNavigator {
  static void goToHome(BuildContext context) => context.go('/home');
  static void goToLogin(BuildContext context) => context.go('/login');
  static void goToRegister(BuildContext context) => context.go('/register');
  static void goToProductDetail(BuildContext context, String productId) => context.go('/product/$productId');
  static void goToAddProduct(BuildContext context) => context.go('/add-product');
  static void goToEditProduct(BuildContext context, String productId) => context.go('/edit-product/$productId');
  static void goToMyProducts(BuildContext context) => context.go('/my-products');
  static void goToAdminDashboard(BuildContext context) => context.go('/admin-dashboard');
  static void goToProfile(BuildContext context) => context.go('/profile');
}
