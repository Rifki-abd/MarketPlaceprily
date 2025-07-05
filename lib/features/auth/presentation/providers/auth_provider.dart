// lib/features/auth/presentation/providers/auth_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/auth/data/auth_repository.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ## Auth Repository Provider
/// Menyediakan instance [AuthRepository] untuk digunakan oleh provider lain.
final AutoDisposeProvider<AuthRepository> authRepositoryProvider = Provider.autoDispose<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});


/// ## Auth State Changes Provider
/// Provider stream mentah yang hanya memberitahukan perubahan state user dari Supabase.
/// Ini adalah dasar untuk provider lainnya.
final AutoDisposeStreamProvider<User?> authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});


/// ## User Profile Provider
/// Mengambil data profil [UserModel] dari user yang sedang login.
/// Ini secara cerdas bergantung pada `authStateChangesProvider`.
final AutoDisposeStreamProvider<UserModel?> userProfileProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  
  // Dapatkan user dari state auth
  final user = authState.valueOrNull;

  if (user != null) {
    // Jika ada user, kembalikan stream profilnya
    return authRepository.getUserProfile(user.id);
  } else {
    // Jika tidak ada user, kembalikan stream yang berisi null
    return Stream.value(null);
  }
});


/// ## Auth Notifier (Untuk Aksi)
/// StateNotifier ini HANYA digunakan untuk melakukan aksi seperti login/logout,
/// dan mengelola state loading/error dari aksi tersebut.
final AutoDisposeStateNotifierProvider<AuthNotifier, AsyncValue<void>> authNotifierProvider = StateNotifierProvider.autoDispose<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._repository) : super(const AsyncData(null));
  final AuthRepository _repository;

  Future<bool> runAction(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } catch(e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> signUp({
    required String email, required String password, required String name,
    required UserRole role, String? waNumber,
  }) => runAction(() => _repository.signUp(email: email, password: password, name: name, role: role, waNumber: waNumber));

  Future<bool> signIn({required String email, required String password}) => runAction(() => _repository.signIn(email: email, password: password));

  Future<bool> signOut() => runAction(_repository.signOut);
}
