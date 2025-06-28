// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../services/auth_service.dart'; // Import authStateProvider
import '../utils/app_router.dart'; // Import AppNavigator

// Mengubah SplashScreen menjadi ConsumerStatefulWidget
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk menavigasi setelah penundaan
    _initAndNavigate();
  }

  void _initAndNavigate() async {
    // Menunda navigasi agar splash screen terlihat selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Gunakan ref.read untuk mendapatkan nilai terakhir dari authStateProvider
    // Ini aman di initState karena kita sudah memastikan provider diinisialisasi di main.dart
    final authState = ref.read(authStateProvider);

    // Dapatkan status otentikasi terakhir
    // Kita perlu memastikan bahwa data sudah tersedia atau ada error
    authState.when(
      data: (user) {
        if (user != null) {
          // Jika user sudah login, arahkan ke Home Screen
          AppNavigator.goToHome(context);
        } else {
          // Jika user belum login, arahkan ke Login Screen
          AppNavigator.goToLogin(context);
        }
      },
      loading: () {
        // Seharusnya tidak masuk ke sini karena kita sudah menunggu stream selesai
        // Tetapi sebagai fallback, kita bisa tetap ke login atau memberikan pesan error
        AppNavigator.goToLogin(context);
      },
      error: (error, stackTrace) {
        // Jika terjadi error, arahkan ke Login Screen
        print('Error during authentication check: $error');
        AppNavigator.goToLogin(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // Menggunakan .withValues() seperti yang disarankan untuk mengganti withOpacity
                    color: const Color.fromARGB(25, 0, 0, 0), // Warna hitam dengan alpha 0.1
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 32),
            
            // App Name
            const Text(
              'Marketplace',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            const Text(
              'Jual Beli Mudah & Terpercaya',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading Indicator
            const SpinKitWave(
              color: Colors.white,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
