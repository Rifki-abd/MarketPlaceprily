// lib/core/routing/app_router.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:preloft_app/features/auth/presentation/screens/login_screen.dart';
import 'package:preloft_app/features/auth/presentation/screens/register_screen.dart';
import 'package:preloft_app/features/auth/presentation/screens/registration_success_screen.dart';
import 'package:preloft_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:preloft_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:preloft_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:preloft_app/features/checkout/presentation/screens/checkout_screen.dart'; // Import baru
import 'package:preloft_app/features/checkout/presentation/screens/order_success_screen.dart'; // Import baru
import 'package:preloft_app/features/common/presentation/screens/splash_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/add_product_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/edit_product_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/home_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/my_products_screen.dart';
import 'package:preloft_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:preloft_app/features/profile/presentation/screens/profile_screen.dart';

// ... (GoRouterRefreshStream tetap sama)
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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream)),
    redirect: (context, state) {
      final isAuthenticating = authState.isLoading || authState.isRefreshing;
      final isLoggedIn = authState.valueOrNull != null;
      final onSplash = state.matchedLocation == '/splash';
      
      if (isAuthenticating) return onSplash ? null : '/splash';
      if (onSplash) return isLoggedIn ? '/home' : '/login';

      final onAuthRoute = state.matchedLocation == '/login' ||
                          state.matchedLocation == '/register' ||
                          state.matchedLocation == '/forgot-password';
      
      if (isLoggedIn && onAuthRoute) return '/home';
      
      final allowedPublicRoutes = ['/register-success'];
      if (!isLoggedIn && !onAuthRoute && !allowedPublicRoutes.contains(state.matchedLocation)) {
        return '/login';
      }
      
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/register-success',
        builder: (context, state) => RegistrationSuccessScreen(
          email: state.uri.queryParameters['email'] ?? 'email Anda',
          isReset: state.uri.queryParameters['isReset'] == 'true',
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/my-products', builder: (context, state) => const MyProductsScreen()),
      GoRoute(path: '/add-product', builder: (context, state) => const AddProductScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/chats', builder: (context, state) => const ChatListScreen()),
      // --- RUTE BARU UNTUK CHECKOUT ---
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(
        path: '/order-success/:id',
        builder: (context, state) => OrderSuccessScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/product/:id', 
        builder: (context, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/edit-product/:id', 
        builder: (context, state) => EditProductScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:id', 
        builder: (context, state) => ChatScreen(chatRoomId: state.pathParameters['id']!),
      ),
    ],
  );
});
