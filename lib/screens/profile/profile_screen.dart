import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_router.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _waNumberController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _waNumberController.dispose();
    super.dispose();
  }

  void _populateFields(UserModel user) {
    _nameController.text = user.name;
    _waNumberController.text = user.waNumber ?? '';
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).updateUserProfile(
        name: _nameController.text.trim(),
        waNumber: _waNumberController.text.trim().isEmpty 
            ? null 
            : _waNumberController.text.trim(),
      );

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authServiceProvider).signOut();
        if (mounted) {
          AppNavigator.goToLogin(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal keluar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          
          // Populate fields when user data is loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isEditing && _nameController.text.isEmpty) {
              _populateFields(user);
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue,
                  child: Text(
                    user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_isEditing) ...[
                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Nama Lengkap',
                            prefixIcon: Icons.person,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _waNumberController,
                            labelText: 'Nomor WhatsApp',
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            hintText: 'Contoh: 08123456789',
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _populateFields(user);
                                    setState(() => _isEditing = false);
                                  },
                                  child: const Text('Batal'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _updateProfile,
                                  child: _isLoading
                                      ? const SpinKitThreeBounce(color: Colors.white, size: 16)
                                      : const Text('Simpan'),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildInfoRow('Nama', user.name, Icons.person),
                          const SizedBox(height: 12),
                          _buildInfoRow('Email', user.email, Icons.email),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Role', 
                            _getRoleDisplayName(user.role), 
                            _getRoleIcon(user.role),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'WhatsApp', 
                            user.waNumber ?? 'Belum diatur', 
                            Icons.phone,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Bergabung', 
                            '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}', 
                            Icons.calendar_today,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Navigation Cards
                if (user.role == UserRole.penjual) ...[
                  _buildNavCard(
                    'Produk Saya',
                    'Kelola produk yang Anda jual',
                    Icons.inventory,
                    () => AppNavigator.goToMyProducts(context),
                  ),
                  const SizedBox(height: 12),
                ],

                if (user.role == UserRole.admin) ...[
                  _buildNavCard(
                    'Admin Dashboard',
                    'Kelola semua produk marketplace',
                    Icons.admin_panel_settings,
                    () => AppNavigator.goToAdminDashboard(context),
                  ),
                  const SizedBox(height: 12),
                ],

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Keluar',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Memuat profile...'),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, currentUserAsync.value),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.penjual:
        return 'Penjual';
      case UserRole.pembeli:
        return 'Pembeli';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.penjual:
        return Icons.store;
      case UserRole.pembeli:
        return Icons.shopping_cart;
    }
  }

  Widget? _buildBottomNavBar(BuildContext context, UserModel? user) {
    if (user == null) return null;

    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
    ];

    List<VoidCallback> onTapCallbacks = [
      () => AppNavigator.goToHome(context),
    ];

    if (user.role == UserRole.penjual) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.inventory),
        label: 'Produk Saya',
      ));
      onTapCallbacks.add(() => AppNavigator.goToMyProducts(context));
    }

    if (user.role == UserRole.admin) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Dashboard',
      ));
      onTapCallbacks.add(() => AppNavigator.goToAdminDashboard(context));
    }

    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ));
    onTapCallbacks.add(() {}); // Already here

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: items.length - 1,
      onTap: (index) => onTapCallbacks[index](),
      items: items,
    );
  }
}