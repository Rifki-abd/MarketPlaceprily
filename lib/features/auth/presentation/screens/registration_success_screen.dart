// lib/features/auth/presentation/screens/registration_success_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({
    required this.email,
    this.isReset = false,
    super.key,
  });
  final String email;
  final bool isReset;

  @override
  Widget build(BuildContext context) {
    final title = isReset ? 'Periksa Email Anda' : 'Pendaftaran Berhasil';
    
    // --- PERBAIKAN DI SINI: Menggunakan ''' untuk string multi-baris ---
    final message = isReset
      ? '''Kami telah mengirimkan tautan untuk mengatur ulang password Anda ke email:
$email'''
      : '''Kami telah mengirimkan tautan konfirmasi ke email Anda di:
$email

Silakan klik tautan tersebut untuk mengaktifkan akun Anda.''';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Kembali ke Halaman Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
