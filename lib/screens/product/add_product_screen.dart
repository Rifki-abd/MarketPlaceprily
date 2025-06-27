import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_text_field.dart';

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
  final _waNumberController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _waNumberController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await ref.read(authServiceProvider).getCurrentUserData();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengguna tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await ref.read(productServiceProvider).createProduct(
        seller: currentUser,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        waNumber: _waNumberController.text.trim(),
      );

      if (mounted) {
        // Use Navigator.pop to go back instead of navigation
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan produk: ${e.toString()}'),
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
        title: const Text('Tambah Produk'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card - No Image Upload
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mode Gratis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload gambar tidak tersedia di versi gratis.\nUpgrade ke Blaze Plan untuk fitur lengkap.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _nameController,
                labelText: 'Nama Produk',
                prefixIcon: Icons.shopping_bag,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Nama produk tidak boleh kosong';
                  if (value!.length < 3) return 'Nama produk minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _priceController,
                labelText: 'Harga (Rp)',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Harga tidak boleh kosong';
                  final price = double.tryParse(value!);
                  if (price == null) return 'Harga harus berupa angka';
                  if (price <= 0) return 'Harga harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Deskripsi',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Deskripsi tidak boleh kosong';
                  if (value!.length < 10) return 'Deskripsi minimal 10 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _locationController,
                labelText: 'Lokasi',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Lokasi tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _waNumberController,
                labelText: 'Nomor WhatsApp',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                hintText: 'Contoh: 08123456789',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Nomor WhatsApp tidak boleh kosong';
                  if (value!.length < 10) return 'Nomor WhatsApp tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                    : const Text(
                        'Tambah Produk',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}