// lib/features/product/presentation/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:preloft_app/features/product/domain/product_model.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart'; // Import LoadingWidget

class ProductCard extends StatelessWidget {

  const ProductCard({
    required this.product, super.key,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });
  final ProductModel product;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // --- PERBAIKAN DI SINI: Menggunakan context.push() ---
        onTap: onTap ?? () => context.push('/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: LoadingWidget());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    )
                  : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(currencyFormatter.format(product.price), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(product.location, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
            if (showActions) _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
        ],
      ),
    );
  }
}
