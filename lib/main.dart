// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marketplace_app/core/routing/app_router.dart';
import 'package:marketplace_app/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Memuat .env dari dalam folder lib
    await dotenv.load(fileName: 'lib/.env');
  } catch (e) {
    print('Error loading .env file: $e'); // Log error jika .env tidak ditemukan
  }

  // Hanya inisialisasi Supabase jika env vars berhasil dimuat
  if (dotenv.isEveryDefined(['SUPABASE_URL', 'SUPABASE_ANON_KEY'])) {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  } else {
    print('Supabase credentials not found in .env file. Supabase not initialized.');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Marketplace App',
      theme: AppTheme.light,
    );
  }
}
