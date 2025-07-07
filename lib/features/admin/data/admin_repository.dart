// lib/features/admin/data/admin_repository.dart

import 'package:preloft_app/features/admin/domain/admin_statistics_model.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepository {
  AdminRepository(this._client);
  final SupabaseClient _client;

  Future<AdminStatistics> getStatistics() async {
    // ... (tidak berubah)
    try {
      final data = await _client.rpc('get_admin_statistics');
      if (data == null) throw Exception('Data statistik tidak ditemukan dari server.');
      return AdminStatistics(
        userCount: (data['user_count'] ?? 0) as int,
        productCount: (data['product_count'] ?? 0) as int,
        orderCount: (data['order_count'] ?? 0) as int,
      );
    } catch (e) { throw Exception('Gagal mengambil statistik admin: $e'); }
  }

  Future<List<UserModel>> getAllUsers() async {
    // ... (tidak berubah)
    try {
      final data = await _client.rpc('get_all_users');
      return (data as List).map((item) => UserModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) { throw Exception('Gagal mendapatkan daftar pengguna: $e'); }
  }

  Future<void> updateUserRole({
    required String userId,
    required UserRole newRole,
  }) async {
    // ... (tidak berubah)
    try {
      await _client.rpc('update_user_role', params: {'p_user_id': userId, 'p_new_role': newRole.name});
    } catch (e) { throw Exception('Gagal memperbarui peran pengguna: $e'); }
  }

  Future<void> changeUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    // ... (tidak berubah)
    try {
      await _client.rpc('admin_change_user_password', params: {'p_user_id': userId, 'p_new_password': newPassword});
    } catch (e) { throw Exception('Gagal mengubah password pengguna: $e'); }
  }

  // --- FUNGSI BARU: Admin menghapus produk ---
  Future<void> deleteProduct({required String productId}) async {
    try {
      await _client.rpc('admin_delete_product', params: {'p_product_id': productId});
    } catch (e) {
      throw Exception('Gagal menghapus produk sebagai admin: $e');
    }
  }
}
