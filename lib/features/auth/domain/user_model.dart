enum UserRole { admin, penjual, pembeli }

class UserModel {

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt, this.waNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: _asString(map['id']),
      name: _asString(map['name']),
      email: _asString(map['email']),
      role: _parseUserRole(map['role']),
      waNumber: map['wa_number']?.toString(),
      createdAt: _asDate(map['created_at']),
    );
  }
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? waNumber;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'wa_number': waNumber,
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

  static UserRole _parseUserRole(dynamic role) {
    if (role is String) {
      return UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == role.toLowerCase(),
        orElse: () => UserRole.pembeli,
      );
    }
    return UserRole.pembeli;
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static DateTime _asDate(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: ${role.name}, waNumber: $waNumber, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            email == other.email &&
            role == other.role &&
            waNumber == other.waNumber &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, role, waNumber, createdAt);
  }
}
