// ignore_for_file: avoid_print

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
  final authState = ref.watch(authStateProvider); // Mengawasi status otentikasi dari authStateProvider
  
  return GoRouter(
    initialLocation: '/splash', // Aplikasi dimulai di SplashScreen
    redirect: (context, state) {
      final currentPath = state.matchedLocation; // Mendapatkan path URL saat ini
      final isLoggingInOrRegistering = currentPath == '/login' || currentPath == '/register';
      final isSplashing = currentPath == '/splash';

      // Jika saat ini berada di splash screen, JANGAN LAKUKAN REDIRECT di sini.
      // Biarkan SplashScreen yang mengontrol navigasi setelah delay-nya.
      if (isSplashing) {
        print('Router Redirect: Currently on /splash, letting SplashScreen handle navigation.');
        return null; 
      }

      // Debug prints (bisa dihapus nanti setelah selesai debugging)
      print('Router Redirect: Current Path = $currentPath');
      print('Router Redirect: Auth State = ${authState.runtimeType}');

      // Logika redirect hanya untuk path SELAIN /splash
      return authState.when(
        data: (user) {
          final isLoggedIn = user != null; // Cek apakah pengguna sudah login
          print('Auth State Data: User Logged In = $isLoggedIn');

          // Jika sudah login
          if (isLoggedIn) {
            // Jika mencoba akses login/register, arahkan ke home
            if (isLoggingInOrRegistering) {
              print('Redirecting to /home because user is logged in and trying to access login/register.');
              return '/home';
            }
            // Jika tidak, biarkan akses ke path yang dituju
            print('Allowing access to current path: $currentPath');
            return null;
          }
          // Jika BELUM login
          else {
            // Jika mencoba akses path yang dilindungi (bukan login/register), arahkan ke login
            if (!isLoggingInOrRegistering) {
              print('Redirecting to /login because user is not logged in and path is protected: $currentPath');
              return '/login';
            }
            // Jika sudah di login/register, biarkan akses.
            print('Allowing access to login/register because user is not logged in.');
            return null;
          }
        },
        loading: () {
          // Selama authState loading (dan kita TIDAK di /splash),
          // arahkan kembali ke splash sampai status auth jelas.
          // Ini sebagai fallback jika ada navigasi ke path lain terlalu cepat.
          print('Auth State Loading: Redirecting to /splash to wait for auth state.');
          return '/splash';
        },
        error: (error, stackTrace) {
          print('Auth State Error: $error');
          print('Auth State Stack Trace: $stackTrace');
          // Jika terjadi error dalam mengambil status otentikasi (dan kita TIDAK di /splash),
          // arahkan ke layar login.
          print('Auth State Error: Redirecting to /login due to authentication error.');
          return '/login';
        },
      );
    },
    routes: [
      // Definisi rute untuk setiap layar di aplikasi
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

// Kelas pembantu untuk navigasi yang lebih mudah
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
