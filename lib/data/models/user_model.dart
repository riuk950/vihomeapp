import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';

/// Modelo de datos de usuario que extiende la entidad User
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.role,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un UserModel desde un User de Supabase
  factory UserModel.fromSupabaseUser(supabase.User user) {
    DateTime? parseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
      role: user.userMetadata?['role'] as String? ?? 'arrendatario',
      createdAt: parseDate(user.createdAt),
      updatedAt: parseDate(user.lastSignInAt ?? user.updatedAt),
    );
  }

  /// Convierte un UserModel a un User (entidad de dominio)
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un UserModel desde un JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'arrendatario',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte un UserModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
