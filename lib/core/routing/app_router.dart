// lib/core/routing/app_router.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/auth/presentation/screens/login_screen.dart';
import 'package:preloft_app/features/auth/presentation/screens/register_screen.dart';
import 'package:preloft_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:preloft_app/features/common/presentation/screens/splash_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/add_product_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/edit_product_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/home_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/my_products_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:preloft_app/features/profile/presentation/screens/profile_screen.dart';

// (Sisa kode di file ini tidak perlu diubah, hanya import di atas)
// ... (tempel sisa kode yang sudah ada di file Anda)
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream));
  
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      
      final isAuthenticating = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      
      final onSplash = state.matchedLocation == '/splash';
      final onAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (isAuthenticating) {
        return onSplash ? null : '/splash';
      }

      if (onSplash) {
        return isLoggedIn ? '/home' : '/login';
      }

      if (isLoggedIn && onAuthRoute) {
        return '/home';
      }

      if (!isLoggedIn && !onAuthRoute) {
        return '/login';
      }

      if (state.matchedLocation == '/admin') {
        final userRole = ref.read(userProfileProvider).valueOrNull?.role;
        if (userRole != UserRole.admin) return '/home';
      }
      
      return null;
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
      GoRoute(
        path: '/product/:id', 
        builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!)
      ),
      GoRoute(
        path: '/edit-product/:id', 
        builder: (context, state) => EditProductScreen(productId: state.pathParameters['id']!)
      ),
    ],
  );
});

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