// lib/features/admin/data/admin_repository.dart

import 'package:preloft_app/features/admin/domain/admin_statistics_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepository {
  AdminRepository(this._client);
  final SupabaseClient _client;

  Future<AdminStatistics> getStatistics() async {
    try {
      final data = await _client.rpc('get_admin_stats');

      if (data == null) {
        // PERBAIKAN: Melemparkan error yang lebih spesifik
        throw Exception('Data statistik tidak ditemukan dari server.');
      }

      // Kode ini sudah baik, tidak ada perubahan fungsional di sini.
      // Peringatan kemungkinan besar ada di file domain atau cara kita
      // menangani error.
      return AdminStatistics(
        userCount: (data['user_count'] ?? 0) as int,
        productCount: (data['product_count'] ?? 0) as int,
      );
    } on PostgrestException catch (e) {
      // PERBAIKAN: Menangkap error spesifik dari Supabase
      print('Error Supabase saat mengambil statistik: ${e.message}');
      throw Exception('Gagal mengambil data statistik dari database.');
    } catch (e) {
      // PERBAIKAN: Menangkap error umum lainnya
      print('Terjadi error tak terduga: $e');
      throw Exception('Gagal mengambil statistik admin. Pastikan Anda login sebagai admin.');
    }
  }
}