// lib/features/auth/presentation/providers/auth_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/auth/data/auth_repository.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// (Provider lain tidak berubah)
final AutoDisposeProvider<AuthRepository> authRepositoryProvider = Provider.autoDispose<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final AutoDisposeStreamProvider<User?> authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final AutoDisposeStreamProvider<UserModel?> userProfileProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final user = authState.valueOrNull;

  if (user != null) {
    return authRepository.getUserProfile(user.id);
  } else {
    return Stream.value(null);
  }
});

// Auth Notifier
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

  // --- FUNGSI BARU UNTUK UBAH PASSWORD ---
  Future<bool> changePassword({required String newPassword}) => runAction(() => _repository.changePassword(newPassword: newPassword));
}
