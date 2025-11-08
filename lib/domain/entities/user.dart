/// Entidad de usuario del dominio
class User {
  final String id;
  final String email;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ (name?.hashCode ?? 0);
}

