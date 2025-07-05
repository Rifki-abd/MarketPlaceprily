// lib/features/profile/data/profile_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// ## Profile Repository
///
/// Bertanggung jawab untuk operasi terkait data profil pengguna,
/// seperti memperbarui informasi pengguna di database Supabase.
class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  /// Memperbarui data profil pengguna di tabel 'users'.
  ///
  /// [userId]: ID pengguna yang profilnya akan diperbarui.
  /// [data]: Map berisi data yang akan diupdate (mis: 'name', 'wa_number').
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from('users').update(data).eq('id', userId);
    } catch (e) {
      // Melempar error untuk ditangani oleh layer presentasi (Notifier).
      throw Exception('Gagal memperbarui profil: $e');
    }
  }
}
