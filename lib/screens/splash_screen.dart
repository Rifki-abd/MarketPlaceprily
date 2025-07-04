import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// SplashScreen sekarang menjadi StatelessWidget yang sederhana.
// Tidak ada lagi initState, async, atau navigasi di sini.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'Marketplace',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48),
            SpinKitWave(color: Colors.white, size: 40.0),
          ],
        ),
      ),
    );
  }
}
