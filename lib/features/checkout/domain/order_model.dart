// lib/features/checkout/domain/order_model.dart

import 'package:preloft_app/features/cart/domain/cart_item_model.dart';

// Merepresentasikan satu baris di tabel 'orders'
class OrderModel {
  final String id;
  final String userId;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });
}

// Merepresentasikan satu baris di tabel 'order_items'
class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double pricePerItem;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.pricePerItem,
  });

  // Helper untuk membuat OrderItem dari CartItem
  factory OrderItemModel.fromCartItem(CartItem cartItem, String orderId) {
    return OrderItemModel(
      id: '', // ID akan digenerate oleh database atau diabaikan
      orderId: orderId,
      productId: cartItem.product.id,
      quantity: cartItem.quantity,
      pricePerItem: cartItem.product.price,
    );
  }
}
