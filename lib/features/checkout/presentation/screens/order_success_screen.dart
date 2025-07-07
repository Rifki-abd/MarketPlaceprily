// lib/features/checkout/presentation/screens/order_success_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({required this.orderId, super.key});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Pembayaran Berhasil!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // --- PERBAIKAN DI SINI: Menggunakan ''' untuk multi-baris ---
              Text(
                '''Pesanan Anda telah berhasil dibuat.
Nomor Pesanan: $orderId''',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali ke Halaman Utama'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
