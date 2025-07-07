// lib/features/admin/presentation/screens/manage_users_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/features/admin/presentation/providers/admin_provider.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:preloft_app/shared/widgets/custom_text_field.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  // --- DIALOG BARU UNTUK MENGUBAH PASSWORD ---
  void _showChangePasswordDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password untuk ${user.name}'),
          content: Form(
            key: formKey,
            child: CustomTextField(
              controller: passwordController,
              labelText: 'Password Baru',
              obscureText: true,
              validator: (val) => val!.length < 6 ? 'Password minimal 6 karakter' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                final success = await ref.read(adminActionNotifierProvider.notifier).changeUserPassword(
                  userId: user.id,
                  newPassword: passwordController.text,
                );

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah.'), backgroundColor: Colors.green),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // --- DIALOG LAMA DIPERBARUI MENJADI MENU ---
  void _showAdminActionsMenu(BuildContext context, WidgetRef ref, UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.supervised_user_circle_outlined),
              title: const Text('Ubah Peran'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                final newRole = user.role == UserRole.pembeli ? UserRole.penjual : UserRole.pembeli;
                ref.read(adminActionNotifierProvider.notifier).updateUserRole(
                  userId: user.id, 
                  newRole: newRole,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.password_outlined),
              title: const Text('Ubah Password'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                _showChangePasswordDialog(context, ref, user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Nonaktifkan Pengguna', style: TextStyle(color: Colors.red)),
              onTap: () {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur nonaktifkan pengguna akan dibuat nanti.')),
                  );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    // Dengarkan state dari AdminActionNotifier untuk menampilkan error
    ref.listen<AsyncValue<void>>(adminActionNotifierProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
      ),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(child: Text(user.name.substring(0, 1).toUpperCase())),
              title: Text(user.name),
              subtitle: Text('${user.email} - Peran: ${user.role.name}'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showAdminActionsMenu(context, ref, user),
                tooltip: 'Opsi Admin',
              ),
            );
          },
        ),
        loading: () => const Center(child: LoadingWidget()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
