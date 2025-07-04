import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../widgets/loading_widget.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await ref.read(productServiceProvider).getProductById(widget.productId);
    if (product != null && mounted) {
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _descriptionController.text = product.description;
      _locationController.text = product.location;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final updates = {
      'name': _nameController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
    };

    try {
      await ref.read(productServiceProvider).updateProduct(widget.productId, updates);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: FutureBuilder<ProductModel?>(
        future: ref.read(productServiceProvider).getProductById(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingWidget();
          if (!snapshot.hasData) return const Center(child: Text('Produk tidak ditemukan'));
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Produk')),
                TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi')),
                TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lokasi')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Update'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
