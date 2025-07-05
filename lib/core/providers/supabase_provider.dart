// lib/core/providers/supabase_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ## Supabase Client Provider
///
/// Provider global yang diekspos untuk menyediakan instance [SupabaseClient].
/// Ini memungkinkan seluruh aplikasi untuk mengakses client Supabase dengan cara yang konsisten.
///
/// Cukup `ref.watch(supabaseClientProvider)` di dalam provider lain untuk menggunakannya.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
