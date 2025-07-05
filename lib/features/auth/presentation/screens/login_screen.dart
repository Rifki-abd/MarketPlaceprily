// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/shared/widgets/custom_text_field.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';
import 'package:marketplace_app/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.shopping_bag, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  Text('Selamat Datang Kembali!', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 32),
                  CustomTextField(controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
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
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState is AsyncLoading ? null : _signIn,
                    child: authState is AsyncLoading ? const LoadingWidget() : const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
