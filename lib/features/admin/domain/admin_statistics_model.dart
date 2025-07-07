// lib/features/admin/domain/admin_statistics_model.dart

class AdminStatistics {
  AdminStatistics({
    required this.userCount,
    required this.productCount,
    required this.orderCount, // Tambahkan properti baru
  });
  
  final int userCount;
  final int productCount;
  final int orderCount; // Properti baru
}
