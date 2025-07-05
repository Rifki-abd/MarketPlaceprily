// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/features/auth/domain/user_model.dart';
import 'package:marketplace_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';
import 'package:marketplace_app/features/profile/presentation/providers/profile_provider.dart';

/// ## Profile Screen
///
/// Layar untuk menampilkan dan mengedit data profil pengguna.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _waController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _waController.dispose();
    super.dispose();
  }

  void _toggleEdit(UserModel user) {
    if (!_isEditing) {
      _nameController.text = user.name;
      _waController.text = user.waNumber ?? '';
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _updateProfile() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    final data = {
      'name': _nameController.text.trim(),
      'wa_number': _waController.text.trim(),
    };
    
    final success = await ref
        .read(profileActionNotifierProvider.notifier)
        .updateProfile(user.id, data);
    
    if (success) {
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileActionState = ref.watch(profileActionNotifierProvider);
    
    ref.listen<AsyncValue>(profileActionNotifierProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString()), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: userProfileAsync.when(
          data: (user) => user != null
              ? [
                  if (profileActionState is! AsyncLoading)
                    IconButton(
                      icon: Icon(_isEditing ? Icons.save : Icons.edit),
                      onPressed: () => _isEditing ? _updateProfile() : _toggleEdit(user),
                    )
                  else
                    const Padding(padding: EdgeInsets.all(16), child: LoadingWidget()) // FIX: Menghapus parameter size
                ]
              : [],
          loading: () => [],
          error: (_, __) => [],
        ),
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Pengguna tidak ditemukan.'));
          return _buildProfileView(user);
        },
        loading: () => const Center(child: LoadingWidget(message: 'Memuat profil...')),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProfileView(UserModel user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_isEditing) ..._buildEditFields() else ..._buildDisplayFields(user),
        const SizedBox(height: 20),
        
        if (user.role == UserRole.penjual)
          ElevatedButton.icon(
            onPressed: () => context.go('/my-products'),
            icon: const Icon(Icons.storefront),
            label: const Text('Produk Saya'),
          ),

        if (user.role == UserRole.admin)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/admin'),
              icon: const Icon(Icons.dashboard_customize),
              label: const Text('Admin Dashboard'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
            ),
          ),

        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () async {
            await ref.read(authProvider.notifier).signOut();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  List<Widget> _buildEditFields() {
    return [
      TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama')),
      const SizedBox(height: 16),
      TextField(controller: _waController, decoration: const InputDecoration(labelText: 'Nomor WhatsApp')),
    ];
  }

  List<Widget> _buildDisplayFields(UserModel user) {
    return [
      ListTile(leading: const Icon(Icons.person), title: const Text('Nama'), subtitle: Text(user.name)),
      ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(user.email)),
      ListTile(leading: const Icon(Icons.phone), title: const Text('Nomor WhatsApp'), subtitle: Text(user.waNumber ?? 'Belum diatur')),
      ListTile(leading: const Icon(Icons.badge), title: const Text('Role'), subtitle: Text(user.role.name == 'admin' ? 'Administrator' : (user.role.name == 'penjual' ? 'Penjual' : 'Pembeli'))),
    ];
  }
}
