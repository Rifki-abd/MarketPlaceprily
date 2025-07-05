// lib/features/auth/data/auth_repository.dart

import 'dart:async';

import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange.map((data) => data.session?.user);

  User? get currentUser => _client.auth.currentUser;
  
  Stream<UserModel?> getUserProfile(String userId) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .limit(1)
        .map((data) => data.isEmpty ? null : UserModel.fromMap(data.first))
        .handleError((error) {
          print('Error getting user profile: $error');
          return null;
        });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? waNumber,
  }) async {
    try {
      await _client.auth.signUp(
        email: email, 
        password: password,
        data: {
          'name': name,
          'role': role.name,
          'wa_number': waNumber,
        }
      );
    } on AuthException catch (e) {
      // PERBAIKAN: Melempar error yang lebih spesifik
      throw Exception('Gagal mendaftar: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga saat mendaftar.');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception('Gagal login: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga saat login.');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Gagal logout: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga saat logout.');
    }
  }
}