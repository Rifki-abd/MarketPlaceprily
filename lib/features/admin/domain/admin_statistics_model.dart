// lib/features/admin/domain/admin_statistics_model.dart

/// ## Admin Statistics Model
///
/// Model data sederhana untuk menampung data statistik yang akan
/// ditampilkan di dashboard admin.
class AdminStatistics {

  // PERBAIKAN: Tambahkan 'const' pada konstruktor.
  const AdminStatistics({
    required this.userCount,
    required this.productCount,
  });
  
  final int userCount;
  final int productCount;
}