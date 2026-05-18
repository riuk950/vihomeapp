/// Entidad de usuario del dominio
class User {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final bool isPremium;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.isPremium = false,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        other.isPremium == isPremium &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      (name?.hashCode ?? 0) ^
      (role?.hashCode ?? 0) ^
      isPremium.hashCode ^
      (createdAt?.hashCode ?? 0) ^
      (updatedAt?.hashCode ?? 0);
}
