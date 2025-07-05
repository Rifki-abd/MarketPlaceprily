// lib/features/product/presentation/screens/add_product_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/product/presentation/providers/product_provider.dart';
import 'package:preloft_app/shared/widgets/custom_text_field.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

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
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCompressImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile == null) return;
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    final result = await FlutterImageCompress.compressAndGetFile(pickedFile.path, targetPath, quality: 80, minWidth: 1080);
    if (result != null) {
      setState(() => _selectedImage = File(result.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih gambar produk.'), backgroundColor: Colors.red));
      return;
    }
    final currentUser = ref.read(userProfileProvider).value;
    if (currentUser == null) return;
    final productData = {
      'seller_id': currentUser.id, 'seller_name': currentUser.name, 'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0, 'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(), 'wa_number': currentUser.waNumber ?? '',
    };
    final success = await ref.read(productActionNotifierProvider.notifier).createProduct(productData, _selectedImage!);
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productActionNotifierProvider);
    ref.listen<AsyncValue<void>>(productActionNotifierProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString()), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickAndCompressImage,
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
                child: _selectedImage != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                  : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: Colors.grey, size: 50), SizedBox(height: 8), Text('Pilih Gambar Produk')]),
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(controller: _nameController, labelText: 'Nama Produk', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 16),
            CustomTextField(controller: _priceController, labelText: 'Harga', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 16),
            CustomTextField(controller: _descriptionController, labelText: 'Deskripsi', maxLines: 3, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 16),
            CustomTextField(controller: _locationController, labelText: 'Lokasi', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: state.isLoading ? const LoadingWidget() : const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}