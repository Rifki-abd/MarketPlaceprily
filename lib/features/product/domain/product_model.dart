// lib/features/product/domain/product_model.dart

class ProductModel { // <-- FIELD PENTING DITAMBAHKAN

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.location,
    required this.sellerName,
    required this.waNumber,
    required this.imageUrl,
    required this.createdAt,
    required this.sellerId, // <-- DIPERLUKAN
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      location: map['location'] as String,
      sellerName: map['seller_name'] as String,
      waNumber: map['wa_number'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      sellerId: map['seller_id'] as String, // <-- MEMBACA DARI DATABASE
    );
  }
  final String id;
  final String name;
  final String description;
  final double price;
  final String location;
  final String sellerName;
  final String waNumber;
  final String? imageUrl;
  final DateTime createdAt;
  final String sellerId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'location': location,
      'seller_name': sellerName,
      'wa_number': waNumber,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'seller_id': sellerId, // <-- MENYIMPAN KE DATABASE
    };
  }
}
