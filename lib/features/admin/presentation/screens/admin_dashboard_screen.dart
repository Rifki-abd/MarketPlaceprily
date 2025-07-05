// lib/features/admin/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/features/admin/presentation/providers/admin_provider.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

/// ## Admin Dashboard Screen
///
/// Layar untuk administrator yang menampilkan statistik utama aplikasi.
/// UI ini sepenuhnya bergantung pada state dari `adminStatisticsProvider`.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          // Tombol refresh untuk memuat ulang data statistik
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminStatisticsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                context,
                icon: Icons.people,
                label: 'Total Pengguna',
                value: stats.userCount.toString(),
                color: Colors.blue,
              ),
              _buildStatCard(
                context,
                icon: Icons.inventory_2,
                label: 'Total Produk',
                value: stats.productCount.toString(),
                color: Colors.green,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: LoadingWidget(message: 'Memuat statistik...')),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Gagal memuat data: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
