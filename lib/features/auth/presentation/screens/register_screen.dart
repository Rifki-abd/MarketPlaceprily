// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/features/auth/domain/user_model.dart';
import 'package:marketplace_app/shared/widgets/custom_text_field.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';
import 'package:marketplace_app/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.pembeli;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: _selectedRole,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(controller: _nameController, labelText: 'Nama Lengkap', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _passwordController, labelText: 'Password', obscureText: true, validator: (v) => v!.length < 6 ? 'Password minimal 6 karakter' : null),
              const SizedBox(height: 24),
              Text('Saya ingin mendaftar sebagai:', style: Theme.of(context).textTheme.titleMedium),
              ...UserRole.values
                  .where((role) => role != UserRole.admin) // Sembunyikan role admin
                  .map((role) => RadioListTile<UserRole>(
                        title: Text(role == UserRole.penjual ? 'Penjual' : 'Pembeli'),
                        value: role,
                        groupValue: _selectedRole,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                      )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authState is AsyncLoading ? null : _submit,
                child: authState is AsyncLoading ? const LoadingWidget() : const Text('Daftar'),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sudah punya akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
