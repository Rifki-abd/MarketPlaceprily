// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/auth/domain/user_model.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/shared/widgets/custom_text_field.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

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
  final _confirmPasswordController = TextEditingController(); // Controller baru
  final _waController = TextEditingController();
  UserRole _selectedRole = UserRole.pembeli;

  // State untuk visibilitas password
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Jangan lupa dispose
    _waController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    
    final success = await ref.read(authNotifierProvider.notifier).signUp(
      email: email,
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
      waNumber: _waController.text.trim(),
    );

    if (success && mounted) {
      context.go('/register-success?email=$email');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
    
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.shopping_bag, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icons.person_outline,
                  validator: (val) => val!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.isEmpty ? 'Email tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                // --- FIELD PASSWORD DIPERBARUI ---
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible, // Kontrol visibilitas
                  validator: (val) => val!.length < 6 ? 'Password minimal 6 karakter' : null,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                const SizedBox(height: 16),
                // --- FIELD KONFIRMASI PASSWORD BARU ---
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Konfirmasi Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible, // Kontrol visibilitas
                  validator: (val) {
                    if (val!.isEmpty) return 'Konfirmasi password wajib diisi';
                    if (val != _passwordController.text) return 'Password tidak cocok';
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
                const SizedBox(height: 16),
                 CustomTextField(
                  controller: _waController,
                  labelText: 'Nomor WhatsApp (Opsional)',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                _buildRoleSelector(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authState.isLoading ? const LoadingWidget() : const Text('Daftar'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Login di sini'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saya ingin mendaftar sebagai:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<UserRole>(
          segments: const [
            ButtonSegment(value: UserRole.pembeli, label: Text('Pembeli'), icon: Icon(Icons.person_outline)),
            ButtonSegment(value: UserRole.penjual, label: Text('Penjual'), icon: Icon(Icons.storefront_outlined)),
          ],
          selected: {_selectedRole},
          onSelectionChanged: (newSelection) {
            setState(() {
              _selectedRole = newSelection.first;
            });
          },
        ),
      ],
    );
  }
}
