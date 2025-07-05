class ProductModel {

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.price,
    required this.description,
    required this.location,
    required this.waNumber, required this.createdAt, required this.updatedAt, this.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: _asString(map['id']),
      sellerId: _asString(map['seller_id']),
      sellerName: _asString(map['seller_name']),
      name: _asString(map['name']),
      price: _asDouble(map['price']),
      description: _asString(map['description']),
      location: _asString(map['location']),
      imageUrl: map['image_url']?.toString(),
      waNumber: _asString(map['wa_number']),
      createdAt: _asDate(map['created_at']),
      updatedAt: _asDate(map['updated_at']),
    );
  }
  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final double price;
  final String description;
  final String location;
  final String? imageUrl;
  final String waNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'name': name,
      'price': price,
      'description': description,
      'location': location,
      'image_url': imageUrl,
      'wa_number': waNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? name,
    double? price,
    String? description,
    String? location,
    String? imageUrl,
    String? waNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      waNumber: waNumber ?? this.waNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper untuk memastikan parsing aman
  static String _asString(dynamic value) => value?.toString() ?? '';
  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static DateTime _asDate(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
