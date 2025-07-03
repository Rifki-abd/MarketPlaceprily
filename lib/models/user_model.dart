enum UserRole { admin, penjual, pembeli }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? waNumber;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.waNumber,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.pembeli,
      ),
      waNumber: map['wa_number'],
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name, // Ensure 'name' is included here
      'email': email,
      'role': role.toString().split('.').last,
      'wa_number': waNumber, // Ensure this is the column name in Supabase
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? waNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      waNumber: waNumber ?? this.waNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}