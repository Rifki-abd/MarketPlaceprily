// lib/features/admin/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/admin/presentation/providers/admin_provider.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      // --- PERBAIKAN DI SINI: Membungkus dengan SingleChildScrollView ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            statsAsync.when(
              data: (stats) => GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context,
                    icon: Icons.people_outline,
                    label: 'Total Pengguna',
                    value: stats.userCount.toString(),
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Total Produk',
                    value: stats.productCount.toString(),
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    icon: Icons.receipt_long_outlined,
                    label: 'Total Pesanan',
                    value: stats.orderCount.toString(),
                    color: Colors.orange,
                  ),
                ],
              ),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: LoadingWidget(message: 'Memuat statistik...'),
              ),),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Kelola Pengguna'),
              subtitle: const Text('Lihat semua pengguna dan ubah peran mereka'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/users'),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Pengaturan Lainnya'),
              subtitle: const Text('Fitur admin lainnya akan muncul di sini'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
