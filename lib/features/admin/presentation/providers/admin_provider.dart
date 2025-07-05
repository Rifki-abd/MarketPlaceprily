// lib/features/admin/presentation/providers/admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketplace_app/core/providers/supabase_provider.dart';
import 'package:marketplace_app/features/admin/data/admin_repository.dart';
import 'package:marketplace_app/features/admin/domain/admin_statistics_model.dart';

/// ## Admin Repository Provider
/// Menyediakan instance [AdminRepository].
final AutoDisposeProvider<AdminRepository> adminRepositoryProvider = Provider.autoDispose<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
});

/// ## Admin Statistics Provider
///
/// [FutureProvider] yang mengambil data statistik admin.
/// Secara otomatis akan menangani state loading, data, dan error untuk UI.
final AutoDisposeFutureProvider<AdminStatistics> adminStatisticsProvider = FutureProvider.autoDispose<AdminStatistics>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getStatistics();
});
