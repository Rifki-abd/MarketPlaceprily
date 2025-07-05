// lib/features/product/presentation/screens/edit_product_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/product/presentation/providers/product_provider.dart';
import 'package:preloft_app/shared/widgets/custom_text_field.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  const EditProductScreen({required this.productId, super.key});
  final String productId;

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gunakan WidgetsBinding untuk memastikan ref bisa diakses setelah build pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialProduct = ref.read(productByIdProvider(widget.productId));
      if (initialProduct != null) {
        _nameController.text = initialProduct.name;
        _priceController.text = initialProduct.price.toStringAsFixed(0);
        _descriptionController.text = initialProduct.description;
        _locationController.text = initialProduct.location;
      }
    });
  }

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

    final updatedData = {
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
    };

    final success = await ref
        .read(productActionNotifierProvider.notifier)
        .updateProduct(widget.productId, updatedData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(productActionNotifierProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(productActionNotifierProvider);
    // Kita juga watch product untuk memastikan UI memiliki data terbaru
    final product = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: product == null
          ? const Center(child: LoadingWidget(message: 'Memuat data produk...'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CustomTextField(
                      controller: _nameController,
                      labelText: 'Nama Produk',
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _priceController,
                      labelText: 'Harga',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Deskripsi',
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _locationController,
                      labelText: 'Lokasi',
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const LoadingWidget()
                        : const Text('Simpan Perubahan'),
                  )
                ],
              ),
            ),
    );
  }
}