import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_router.dart';
import '../../widgets/custom_text_field.dart';

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
  final _confirmPasswordController = TextEditingController();
  final _waNumberController = TextEditingController();
  
  UserRole _selectedRole = UserRole.pembeli;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _waNumberController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // BAGIAN INI ADALAH PANGGILAN UNTUK REGISTRASI
      await ref.read(authServiceProvider).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        waNumber: _waNumberController.text.trim().isEmpty 
            ? null 
            : _waNumberController.text.trim(),
      );
      
      if (mounted) {
        AppNavigator.goToHome(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppNavigator.goToLogin(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add,
                  size: 60,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  'Buat Akun Baru',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Nama tidak boleh kosong';
                    if (value!.length < 2) return 'Nama minimal 2 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email tidak boleh kosong';
                    if (!value!.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password tidak boleh kosong';
                    if (value!.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Konfirmasi Password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Konfirmasi password tidak boleh kosong';
                    if (value != _passwordController.text) return 'Password tidak sama';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _waNumberController,
                  labelText: 'Nomor WhatsApp (Opsional)',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                  hintText: 'Contoh: 08123456789',
                ),
                const SizedBox(height: 24),
                Text(
                  'Pilih Role',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: UserRole.values.map((role) {
                    String roleText = '';
                    String roleDescription = '';
                    
                    switch (role) {
                      case UserRole.pembeli:
                        roleText = 'Pembeli';
                        roleDescription = 'Dapat melihat dan menghubungi penjual';
                        break;
                      case UserRole.penjual:
                        roleText = 'Penjual';
                        roleDescription = 'Dapat menjual dan mengelola produk';
                        break;
                      case UserRole.admin:
                        roleText = 'Admin';
                        roleDescription = 'Dapat mengelola semua produk';
                        break;
                    }
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: RadioListTile<UserRole>(
                        title: Text(
                          roleText,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(roleDescription),
                        value: role,
                        groupValue: _selectedRole,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                      : const Text('Daftar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ', style: TextStyle(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () => AppNavigator.goToLogin(context),
                      child: const Text('Login'),
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
}