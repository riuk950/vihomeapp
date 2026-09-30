import '../../domain/entities/review.dart';

/// Modelo de datos para Calificaciones, compatible con Supabase
class ReviewModel extends Review {
  ReviewModel({
    required super.id,
    required super.solicitudId,
    required super.reviewerId,
    super.reviewerName,
    required super.targetUserId,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  /// Crea un ReviewModel desde un mapa JSON (Supabase)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is DateTime) return date;
      if (date is String) return DateTime.parse(date);
      return DateTime.now();
    }

    return ReviewModel(
      id: json['id'] as String,
      solicitudId: json['solicitud_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewerName: json['reviewer_name'] as String?,
      targetUserId: json['target_user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: parseDate(json['created_at']),
    );
  }

  /// Serializa a JSON para inserciones o respuestas
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solicitud_id': solicitudId,
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'target_user_id': targetUserId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
