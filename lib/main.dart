// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/app_init_provider.dart'; // Import provider baru
import 'package:preloft_app/core/routing/app_router.dart';
import 'package:preloft_app/core/theme/app_theme.dart';
import 'package:preloft_app/features/common/presentation/screens/splash_screen.dart'; // Import SplashScreen

// Fungsi main sekarang sangat sederhana dan sinkron.
// Tidak ada lagi 'await' yang menyebabkan layar putih.
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton (watch) provider inisialisasi.
    final initialization = ref.watch(appInitializationProvider);

    // Gunakan 'when' untuk menampilkan UI yang berbeda berdasarkan state inisialisasi.
    return initialization.when(
      // Saat sedang loading, tampilkan SplashScreen.
      loading: () => const MaterialApp(home: SplashScreen()),
      
      // Jika terjadi error saat inisialisasi, tampilkan halaman error.
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Gagal memulai aplikasi: $err'),
          ),
        ),
      ),
      
      // Jika inisialisasi berhasil, bangun aplikasi utama dengan router.
      data: (_) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          title: 'Preloft',
          theme: AppTheme.light,
        );
      },
    );
  }
}
