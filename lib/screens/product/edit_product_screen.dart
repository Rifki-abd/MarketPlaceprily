import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final String productId;

  const EditProductScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _waNumberController = TextEditingController();

  ProductModel? _currentProduct;
  bool _isLoading = false;
  bool _isLoadingProduct = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _waNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await ref.read(productServiceProvider).getProductById(widget.productId);
      if (product != null && mounted) {
        setState(() {
          _currentProduct = product;
          _nameController.text = product.name;
          _priceController.text = product.price.toString();
          _descriptionController.text = product.description;
          _locationController.text = product.location;
          _waNumberController.text = product.waNumber;
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProduct = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat produk: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate() || _currentProduct == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(productServiceProvider).updateProduct(
        productId: widget.productId,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        waNumber: _waNumberController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui produk: ${e.toString()}'),
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
    if (_isLoadingProduct) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Produk')),
        body: const LoadingWidget(message: 'Memuat data produk...'),
      );
    }

    if (_currentProduct == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Produk')),
        body: const Center(
          child: Text('Produk tidak ditemukan'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                          : const Text(
                              'Update Produk',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}