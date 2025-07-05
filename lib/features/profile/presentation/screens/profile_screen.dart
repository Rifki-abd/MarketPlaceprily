// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:preloft_app/shared/widgets/custom_text_field.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

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

  void _initializeControllers(UserModel user) {
    _nameController.text = user.name;
    _waController.text = user.waNumber ?? '';
  }

  void _toggleEdit(UserModel user) {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _initializeControllers(user);
      }
    });
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
    
    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileActionState = ref.watch(profileActionNotifierProvider);
    
    ref.listen<AsyncValue>(profileActionNotifierProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
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
                  if (profileActionState is AsyncLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    )
                  else
                    IconButton(
                      icon: Icon(_isEditing ? Icons.save_alt_outlined : Icons.edit_outlined),
                      onPressed: () => _isEditing ? _updateProfile() : _toggleEdit(user),
                      tooltip: _isEditing ? 'Simpan' : 'Edit Profil',
                    )
                ]
              : [],
          loading: () => [],
          error: (_, __) => [],
        ),
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Pengguna tidak ditemukan. Silakan login kembali.'));
          }
          if (!_isEditing) {
              _initializeControllers(user);
          }
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
        const SizedBox(height: 32),
        
        if (user.role == UserRole.penjual) ...[
          ElevatedButton.icon(
            onPressed: () => context.push('/my-products'),
            // PERBAIKAN: Menambahkan 'const'
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Produk Saya'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12)
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (user.role == UserRole.admin) ...[
          ElevatedButton.icon(
            onPressed: () => context.push('/admin'),
            // PERBAIKAN: Menambahkan 'const'
            icon: const Icon(Icons.dashboard_customize_outlined),
            label: const Text('Admin Dashboard'),
             style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 12)
            ),
          ),
          const SizedBox(height: 8),
        ],

        ElevatedButton.icon(
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).signOut();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700, 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12)
          ),
          // PERBAIKAN: Menambahkan 'const'
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  List<Widget> _buildEditFields() {
    return [
      CustomTextField(controller: _nameController, labelText: 'Nama', prefixIcon: Icons.person_outline),
      const SizedBox(height: 16),
      CustomTextField(controller: _waController, labelText: 'Nomor WhatsApp', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
    ];
  }

  List<Widget> _buildDisplayFields(UserModel user) {
    return [
      ListTile(
        // PERBAIKAN: Menambahkan 'const'
        leading: const Icon(Icons.person_outline), 
        title: const Text('Nama'), 
        subtitle: Text(user.name, style: Theme.of(context).textTheme.titleMedium)
      ),
      const Divider(),
      ListTile(
        // PERBAIKAN: Menambahkan 'const'
        leading: const Icon(Icons.email_outlined), 
        title: const Text('Email'), 
        subtitle: Text(user.email, style: Theme.of(context).textTheme.titleMedium)
      ),
      const Divider(),
      ListTile(
        // PERBAIKAN: Menambahkan 'const'
        leading: const Icon(Icons.phone_outlined), 
        title: const Text('Nomor WhatsApp'), 
        subtitle: Text(user.waNumber ?? 'Belum diatur', style: Theme.of(context).textTheme.titleMedium)
      ),
      const Divider(),
      ListTile(
        // PERBAIKAN: Menambahkan 'const'
        leading: const Icon(Icons.badge_outlined), 
        title: const Text('Role'), 
        subtitle: Text(user.role.name.substring(0, 1).toUpperCase() + user.role.name.substring(1), style: Theme.of(context).textTheme.titleMedium)
      ),
    ];
  }
}