// lib/features/product/presentation/screens/add_product_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:marketplace_app/shared/widgets/custom_text_field.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';
import 'package:marketplace_app/features/product/presentation/providers/product_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});
  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final currentUser = ref.read(userProfileProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Anda harus login untuk membuat produk.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final productData = {
      'seller_id': currentUser.id,
      'seller_name': currentUser.name,
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'wa_number': currentUser.waNumber ?? '',
    };
    
    final success = await ref.read(productActionNotifierProvider.notifier).createProduct(productData);
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the action notifier for errors
    ref.listen<AsyncValue<void>>(productActionNotifierProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString()), backgroundColor: Colors.red),
        );
      }
    });

    final state = ref.watch(productActionNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(controller: _nameController, labelText: 'Nama Produk', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 16),
            CustomTextField(controller: _priceController, labelText: 'Harga', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 16),
            CustomTextField(controller: _descriptionController, labelText: 'Deskripsi', maxLines: 3, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 16),
            CustomTextField(controller: _locationController, labelText: 'Lokasi', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading ? const LoadingWidget() : const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}
