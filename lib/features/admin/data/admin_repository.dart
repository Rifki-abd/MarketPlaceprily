// lib/features/admin/data/admin_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marketplace_app/features/admin/domain/admin_statistics_model.dart';

class AdminRepository {
  AdminRepository(this._client);
  final SupabaseClient _client;

  Future<AdminStatistics> getStatistics() async {
    try {
      final response = await _client.rpc('get_admin_stats');
      
      if (response.isEmpty || response.first == null) {
        throw Exception('Data statistik tidak ditemukan atau format tidak valid.');
      }
      
      final data = response.first as Map<String, dynamic>;

      return AdminStatistics(
        userCount: data['user_count'] as int,
        productCount: data['product_count'] as int,
      );
    } catch (e) {
      throw Exception('Gagal mengambil statistik admin: $e');
    }
  }
}
