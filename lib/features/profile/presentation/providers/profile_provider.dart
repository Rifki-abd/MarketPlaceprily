// lib/features/profile/presentation/providers/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketplace_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:marketplace_app/core/providers/supabase_provider.dart';
import 'package:marketplace_app/features/profile/data/profile_repository.dart';

/// ## Profile Repository Provider
///
/// Menyediakan instance [ProfileRepository] untuk digunakan oleh provider lain.
final AutoDisposeProvider<ProfileRepository> profileRepositoryProvider = Provider.autoDispose<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

/// ## Profile Action Notifier Provider
///
/// StateNotifier untuk menangani state (loading, error, data) dari aksi
/// yang berhubungan dengan profil, seperti `updateProfile`.
final AutoDisposeStateNotifierProvider<ProfileActionNotifier, AsyncValue<void>> profileActionNotifierProvider =
    StateNotifierProvider.autoDispose<ProfileActionNotifier, AsyncValue<void>>((ref) {
  return ProfileActionNotifier(
    ref.watch(profileRepositoryProvider),
    ref,
  );
});

class ProfileActionNotifier extends StateNotifier<AsyncValue<void>> {

  ProfileActionNotifier(this._repository, this._ref) : super(const AsyncData(null));
  final ProfileRepository _repository;
  final Ref _ref;

  /// Menjalankan aksi pembaruan profil dan mengelola state.
  ///
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repository.updateUserProfile(userId: userId, data: data);
      // Invalidate provider profil user agar UI mendapatkan data terbaru.
      _ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
