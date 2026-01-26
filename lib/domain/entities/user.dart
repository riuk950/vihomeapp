/// Entidad de usuario del dominio
class User {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      (name?.hashCode ?? 0) ^
      (role?.hashCode ?? 0) ^
      (createdAt?.hashCode ?? 0) ^
      (updatedAt?.hashCode ?? 0);
}
