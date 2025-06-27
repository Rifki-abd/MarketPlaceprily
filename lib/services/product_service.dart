import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

final productServiceProvider = Provider<ProductService>((ref) => ProductService());

final allProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('products')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList());
});

final myProductsProvider = StreamProvider.family<List<ProductModel>, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('products')
      .where('seller_id', isEqualTo: sellerId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList());
});

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProductModel> createProduct({
    required UserModel seller,
    required String name,
    required double price,
    required String description,
    required String location,
    required String waNumber,
  }) async {
    try {
      final docRef = _firestore.collection('products').doc();
      
      // Use placeholder image or no image for free tier
      String? imageUrl;
      // imageUrl = 'https://via.placeholder.com/400x300?text=Product+Image';

      final product = ProductModel(
        id: docRef.id,
        sellerId: seller.id,
        sellerName: seller.name,
        name: name,
        price: price,
        description: description,
        location: location,
        imageUrl: imageUrl, // null for now
        waNumber: waNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(product.toMap());
      return product;
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  Future<void> updateProduct({
    required String productId,
    String? name,
    double? price,
    String? description,
    String? location,
    String? waNumber,
  }) async {
    try {
      final Map<String, dynamic> updates = {'updated_at': Timestamp.now()};
      
      if (name != null) updates['name'] = name;
      if (price != null) updates['price'] = price;
      if (description != null) updates['description'] = description;
      if (location != null) updates['location'] = location;
      if (waNumber != null) updates['wa_number'] = waNumber;
      
      // Skip image update for free tier
      // if (imageFile != null) {
      //   final imageUrl = await uploadImage(imageFile, productId);
      //   updates['image_url'] = imageUrl;
      // }

      await _firestore.collection('products').doc(productId).update(updates);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Delete document from Firestore
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data()!);
      }
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
    return null;
  }

  Stream<List<ProductModel>> searchProducts(String query) {
    if (query.isEmpty) {
      return _firestore
          .collection('products')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data()))
              .toList());
    }

    return _firestore
        .collection('products')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(query.toLowerCase()) ||
                product.location.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  Stream<List<ProductModel>> getProductsByLocation(String location) {
    return _firestore
        .collection('products')
        .where('location', isEqualTo: location)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }
}