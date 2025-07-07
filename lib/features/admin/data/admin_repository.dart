// lib/features/admin/data/admin_repository.dart

import 'package:preloft_app/features/admin/domain/admin_statistics_model.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepository {
  AdminRepository(this._client);
  final SupabaseClient _client;

  Future<AdminStatistics> getStatistics() async {
    try {
      final data = await _client.rpc('get_admin_statistics');
      if (data == null) {
        throw Exception('Data statistik tidak ditemukan dari server.');
      }
      return AdminStatistics(
        userCount: (data['user_count'] ?? 0) as int,
        productCount: (data['product_count'] ?? 0) as int,
        orderCount: (data['order_count'] ?? 0) as int,
      );
    } catch (e) {
      throw Exception('Gagal mengambil statistik admin: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final data = await _client.rpc('get_all_users');
      final userList = (data as List).map((item) => UserModel.fromMap(item as Map<String, dynamic>)).toList();
      return userList;
    } catch (e) {
      throw Exception('Gagal mendapatkan daftar pengguna: $e');
    }
  }

  Future<void> updateUserRole({
    required String userId,
    required UserRole newRole,
  }) async {
    try {
      await _client.rpc('update_user_role', params: {
        'p_user_id': userId,
        'p_new_role': newRole.name,
      },);
    } catch (e) {
      throw Exception('Gagal memperbarui peran pengguna: $e');
    }
  }

  // --- FUNGSI BARU: Admin mengubah password pengguna ---
  Future<void> changeUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      await _client.rpc('admin_change_user_password', params: {
        'p_user_id': userId,
        'p_new_password': newPassword,
      },);
    } catch (e) {
      throw Exception('Gagal mengubah password pengguna: $e');
    }
  }
}
