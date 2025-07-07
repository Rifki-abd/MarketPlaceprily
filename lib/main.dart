// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/routing/app_router.dart';
import 'package:preloft_app/core/theme/app_theme.dart';
import 'package:preloft_app/features/common/presentation/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // Pastikan binding Flutter siap sebelum melakukan apa pun.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Jalankan App Shell, yang akan menangani proses inisialisasi.
  runApp(const ProviderScope(child: AppShell()));
}

// Widget ini bertanggung jawab untuk inisialisasi dan menampilkan UI yang sesuai.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Gunakan Future untuk melacak status inisialisasi.
  late final Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    // Mulai proses inisialisasi saat widget pertama kali dibuat.
    _initializationFuture = _initializeApp();
  }

  // Fungsi untuk melakukan semua tugas startup yang berat.
  Future<void> _initializeApp() async {
    try {
      // 1. Muat environment variables.
      await dotenv.load(fileName: 'lib/.env');
      
      // 2. Inisialisasi Supabase.
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
    } catch (e) {
      // Jika ada error, lemparkan lagi agar FutureBuilder bisa menangkapnya.
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder akan secara otomatis membangun ulang UI berdasarkan status Future.
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // Jika terjadi error selama inisialisasi, tampilkan pesan error yang jelas.
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Gagal memulai aplikasi. Error: ${snapshot.error}'),
                ),
              ),
            ),
          );
        }

        // Jika inisialisasi selesai dengan sukses, tampilkan aplikasi utama.
        if (snapshot.connectionState == ConnectionState.done) {
          return const MainApp();
        }

        // Selama proses inisialisasi, tampilkan SplashScreen.
        // Ini akan selalu menjadi hal pertama yang dilihat pengguna.
        return const MaterialApp(
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// Ini adalah aplikasi utama Anda, yang hanya akan dibangun setelah inisialisasi selesai.
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Preloft',
      theme: AppTheme.light,
    );
  }
}
