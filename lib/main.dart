import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://lbrltlhnwsncanopvwbx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxicmx0bGhud3NuY2Fub3B2d2J4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExMjQ4NzMsImV4cCI6MjA2NjcwMDg3M30.D9cXvZg367Zswcahq83bGsz0RM2gwO4kkzc-ztNcrQs',
  );

  runApp(const ProviderScope(child: MarketplaceApp()));
}

class MarketplaceApp extends ConsumerWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Marketplace App',
      // theme: AppTheme.lightTheme, // Remove if AppTheme is no longer needed without Firebase
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}