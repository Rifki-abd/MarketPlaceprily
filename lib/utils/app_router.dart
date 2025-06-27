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
      return authState.when(
        data: (user) {
          final isLoggedIn = user != null;
          final currentPath = state.matchedLocation;
          final isLoggingIn = currentPath == '/login' || currentPath == '/register';
          
          if (!isLoggedIn && !isLoggingIn && currentPath != '/splash') {
            return '/login';
          }
          if (isLoggedIn && isLoggingIn) {
            return '/home';
          }
          return null;
        },
        loading: () => '/splash',
        error: (_, __) => '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/add-product',
        name: 'add_product',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/edit-product/:id',
        name: 'edit_product',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return EditProductScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/my-products',
        name: 'my_products',
        builder: (context, state) => const MyProductsScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        name: 'admin_dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class AppNavigator {
  static void goToHome(BuildContext context) {
    context.go('/home');
  }
  
  static void goToLogin(BuildContext context) {
    context.go('/login');
  }
  
  static void goToRegister(BuildContext context) {
    context.go('/register');
  }
  
  static void goToProductDetail(BuildContext context, String productId) {
    context.go('/product/$productId');
  }
  
  static void goToAddProduct(BuildContext context) {
    context.go('/add-product');
  }
  
  static void goToEditProduct(BuildContext context, String productId) {
    context.go('/edit-product/$productId');
  }
  
  static void goToMyProducts(BuildContext context) {
    context.go('/my-products');
  }
  
  static void goToAdminDashboard(BuildContext context) {
    context.go('/admin-dashboard');
  }
  
  static void goToProfile(BuildContext context) {
    context.go('/profile');
  }
}