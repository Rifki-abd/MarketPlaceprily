// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/routing/app_router.dart'; // NAMA BARU
import 'package:preloft_app/core/theme/app_theme.dart';     // NAMA BARU
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: 'lib/.env');
  } catch (e) {
    print('Error loading .env file: $e'); 
  }

  if (dotenv.isEveryDefined(['SUPABASE_URL', 'SUPABASE_ANON_KEY'])) {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  } else {
    print('Kredensial Supabase tidak ditemukan. Supabase tidak diinisialisasi.');
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
      title: 'Preloft',
      theme: AppTheme.light,
    );
  }
}