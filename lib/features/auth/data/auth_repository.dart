// lib/features/auth/data/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marketplace_app/features/auth/domain/user_model.dart';

/// ## Auth Repository
///
/// Bertanggung jawab untuk semua interaksi terkait autentikasi dengan Supabase.
/// Layer ini adalah satu-satunya bagian dari fitur 'auth' yang mengetahui tentang Supabase.
///
/// Dipanggil oleh `AuthProvider` (StateNotifier) di layer presentasi.
class AuthRepository {

  AuthRepository(this._client);
  final SupabaseClient _client;

  /// Mendapatkan stream perubahan status autentikasi dari Supabase.
  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange.map((data) => data.session?.user);

  /// Mendapatkan user yang sedang login saat ini.
  User? get currentUser => _client.auth.currentUser;
  
  /// Mendapatkan data profil user dari tabel 'users'.
  Stream<UserModel?> getUserProfile(String userId) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .limit(1)
        .map((data) => data.isEmpty ? null : UserModel.fromMap(data.first));
  }

  /// Mendaftarkan user baru dengan email, password, dan data tambahan.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? waNumber,
  }) async {
    try {
      final response = await _client.auth.signUp(email: email, password: password);
      if (response.user == null) {
        throw const AuthException('Sign up failed: User is null.');
      }
      
      final userModel = UserModel(
        id: response.user!.id,
        name: name,
        email: email,
        role: role,
        waNumber: waNumber,
        createdAt: DateTime.now(),
      );
      await _client.from('users').insert(userModel.toMap());

    } on AuthException catch (e) {
      // Melempar kembali error spesifik untuk ditangani oleh Notifier
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred during sign up.';
    }
  }

  /// Login user dengan email dan password.
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred during sign in.';
    }
  }

  /// Logout user.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw 'An unexpected error occurred during sign out.';
    }
  }
}
