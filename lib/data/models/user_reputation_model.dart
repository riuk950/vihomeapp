import '../../domain/entities/user_reputation.dart';

/// Modelo de datos para Reputación de usuario
class UserReputationModel extends UserReputation {
  const UserReputationModel({
    required super.userId,
    super.userName,
    super.isVerified,
    super.averageRating,
    super.totalReviews,
  });

  /// Construye un UserReputationModel desde una respuesta agregada de base de datos
  factory UserReputationModel.fromJson(Map<String, dynamic> json) {
    double? parseRating(dynamic rawRating) {
      if (rawRating == null) return null;
      if (rawRating is num) return rawRating.toDouble();
      return double.tryParse(rawRating.toString());
    }

    return UserReputationModel(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      averageRating: parseRating(json['average_rating']),
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convierte a JSON para persistencia o transporte
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'is_verified': isVerified,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}
