// lib/core/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import providers dan screens
import 'package:marketplace_app/features/auth/domain/user_model.dart';
import 'package:marketplace_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:marketplace_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:marketplace_app/features/auth/presentation/screens/login_screen.dart';
import 'package:marketplace_app/features/auth/presentation/screens/register_screen.dart';
import 'package:marketplace_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:marketplace_app/features/common/presentation/screens/splash_screen.dart';
import 'package:marketplace_app/features/product/presentation/screens/add_product_screen.dart';
import 'package:marketplace_app/features/product/presentation/screens/edit_product_screen.dart';
import 'package:marketplace_app/features/product/presentation/screens/home_screen.dart';
import 'package:marketplace_app/features/product/presentation/screens/my_products_screen.dart';
import 'package:marketplace_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:marketplace_app/features/profile/presentation/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // GoRouter akan reaktif terhadap perubahan auth state
  final refreshNotifier = GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream));
  
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // Dapatkan state auth TERKINI menggunakan .read() karena refreshListenable sudah menangani rebuild
      final authState = ref.read(authStateChangesProvider);
      
      final isLoggedIn = authState.hasValue && authState.value != null;
      final isAuthenticating = authState.isLoading;

      final currentLocation = state.uri.toString();
      final isGoingToSplash = currentLocation == '/splash';
      final isGoingToAuth = currentLocation == '/login' || currentLocation == '/register';

      // Jika masih loading dan belum di splash, arahkan ke splash
      if (isAuthenticating && !isGoingToSplash) return '/splash';

      // Jika sudah login
      if (isLoggedIn) {
        // dan mencoba ke splash atau halaman auth, redirect ke home
        if (isGoingToSplash || isGoingToAuth) return '/home';
        
        // Amankan rute admin
        if (state.matchedLocation == '/admin') {
          final userRole = ref.read(userProfileProvider).valueOrNull?.role;
          if (userRole != UserRole.admin) return '/home'; // Akses ditolak
        }
      } else { // Jika tidak login
        // dan tidak sedang di splash atau halaman auth, redirect ke login
        if (!isGoingToSplash && !isGoingToAuth) return '/login';
      }
      
      return null; // Tidak perlu redirect
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/my-products', builder: (context, state) => const MyProductsScreen()),
      GoRoute(path: '/add-product', builder: (context, state) => const AddProductScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/product/:id', builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!)),
      GoRoute(path: '/edit-product/:id', builder: (context, state) => EditProductScreen(productId: state.pathParameters['id']!)),
    ],
  );
});

// Helper untuk membuat GoRouter reaktif terhadap stream perubahan auth
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
