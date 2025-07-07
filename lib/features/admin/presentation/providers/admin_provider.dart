// lib/features/admin/presentation/providers/admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/admin/data/admin_repository.dart';
import 'package:preloft_app/features/admin/domain/admin_statistics_model.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:preloft_app/features/product/presentation/providers/product_provider.dart'; // Import product provider

// ... (provider lain tidak berubah)
final adminRepositoryProvider = Provider.autoDispose<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
});

final adminStatisticsProvider = FutureProvider.autoDispose<AdminStatistics>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return adminRepo.getStatistics();
});

final allUsersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return adminRepo.getAllUsers();
});

// Notifier Aksi Admin
final adminActionNotifierProvider = 
    StateNotifierProvider.autoDispose<AdminActionNotifier, AsyncValue<void>>((ref) {
  return AdminActionNotifier(ref);
});

class AdminActionNotifier extends StateNotifier<AsyncValue<void>> {
  AdminActionNotifier(this._ref) : super(const AsyncData(null));
  final Ref _ref;

  Future<bool> _runAction(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateUserRole({required String userId, required UserRole newRole}) {
    return _runAction(() async {
      await _ref.read(adminRepositoryProvider).updateUserRole(userId: userId, newRole: newRole);
      _ref.invalidate(allUsersProvider);
    });
  }

  Future<bool> changeUserPassword({required String userId, required String newPassword}) {
    return _runAction(() => _ref.read(adminRepositoryProvider).changeUserPassword(
      userId: userId, 
      newPassword: newPassword,
    ),);
  }
  
  // --- FUNGSI BARU UNTUK ADMIN MENGHAPUS PRODUK ---
  Future<bool> deleteProductAsAdmin({required String productId}) {
    return _runAction(() async {
      await _ref.read(adminRepositoryProvider).deleteProduct(productId: productId);
      // Invalidate stream produk agar daftar diperbarui
      _ref.invalidate(allProductsStreamProvider);
    });
  }
}
