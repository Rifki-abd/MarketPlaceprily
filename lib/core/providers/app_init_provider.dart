// lib/core/providers/app_init_provider.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider ini akan melakukan semua pekerjaan inisialisasi asinkron.
// Kita akan memanggilnya sekali dan hasilnya akan di-cache.
final appInitializationProvider = FutureProvider<void>((ref) async {
  // 1. Muat environment variables
  await dotenv.load(fileName: 'lib/.env');
  
  // 2. Inisialisasi Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
});
