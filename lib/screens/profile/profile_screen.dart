import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

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
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final data = {
      'name': _nameController.text.trim(),
      'wa_number': _waController.text.trim(),
    };
    await ref.read(authServiceProvider).updateUserProfile(userId: user.id, data: data);
    setState(() => _isEditing = false);
    ref.refresh(currentUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          userAsync.when(
            data: (user) => user != null
                ? IconButton(
                    icon: Icon(_isEditing ? Icons.save : Icons.edit),
                    onPressed: () => _isEditing ? _updateProfile() : _toggleEdit(user),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Pengguna tidak ditemukan.'));
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (_isEditing) ...[
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama')),
                TextFormField(controller: _waController, decoration: const InputDecoration(labelText: 'Nomor WhatsApp')),
              ] else ...[
                ListTile(title: const Text('Nama'), subtitle: Text(user.name)),
                ListTile(title: const Text('Email'), subtitle: Text(user.email)),
                ListTile(title: const Text('Nomor WhatsApp'), subtitle: Text(user.waNumber ?? 'N/A')),
                ListTile(title: const Text('Role'), subtitle: Text(user.role.name)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (mounted) context.go('/login');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
