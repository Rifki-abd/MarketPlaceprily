// lib/features/product/presentation/screens/edit_product_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_app/shared/widgets/custom_text_field.dart';
import 'package:marketplace_app/shared/widgets/loading_widget.dart';
import 'package:marketplace_app/features/product/presentation/providers/product_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  const EditProductScreen({super.key, required this.productId});
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

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final initialProduct = ref.read(productByIdProvider(widget.productId));
      if (initialProduct != null) {
        _nameController.text = initialProduct.name;
        _priceController.text = initialProduct.price.toStringAsFixed(0);
        _descriptionController.text = initialProduct.description;
        _locationController.text = initialProduct.location;
      }
      _isInitialized = true;
    }
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
    // ... (logic remains the same)
  }

  @override
  Widget build(BuildContext context) {
    // ... (build logic remains the same)
    return const Scaffold(); // Placeholder
  }
}
