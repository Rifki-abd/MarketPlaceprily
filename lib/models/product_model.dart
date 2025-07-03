class ProductModel {
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

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.price,
    required this.description,
    required this.location,
    this.imageUrl,
    required this.waNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  // Assuming timestamp fields from Supabase are ISO 8601 strings
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] is int ? map['id'].toString() : map['id'] ?? '', // Handle potential integer ID from Supabase
      sellerId: map['seller_id'] ?? '',
      sellerName: map['seller_name'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['image_url'], // Assuming image_url can be null
      waNumber: map['wa_number'] ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }


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
      'wa_number': waNumber, // Ensure this is the column name in Supabase
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
}