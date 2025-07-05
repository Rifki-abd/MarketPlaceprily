// lib/features/common/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';

/// ## Splash Screen
///
/// Tampilan awal yang muncul saat aplikasi sedang memuat
/// data awal atau memeriksa status autentikasi.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Marketplace',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48),
            LoadingWidget(message: 'Memuat...'), // FIX: Menghapus parameter color
          ],
        ),
      ),
    );
  }
}
