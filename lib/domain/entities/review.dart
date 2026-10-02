import '../../core/errors/review_exceptions.dart';

/// Entidad inmutable de Calificación del dominio
class Review {
  final String id;
  final String? solicitudId;
  final String reviewerId;
  final String? reviewerName;
  final String targetUserId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    this.solicitudId,
    required this.reviewerId,
    this.reviewerName,
    required this.targetUserId,
    required this.rating,
    this.comment,
    required this.createdAt,
  }) {
    if (solicitudId != null && reviewerId == targetUserId) {
      throw const SelfRatingNotAllowedException();
    }
    if (rating < 1 || rating > 5) {
      throw ReviewValidationException(
        'La puntuación debe ser un valor entero entre 1 y 5 (recibido: $rating).',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.solicitudId == solicitudId &&
        other.reviewerId == reviewerId &&
        other.reviewerName == reviewerName &&
        other.targetUserId == targetUserId &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      solicitudId.hashCode ^
      reviewerId.hashCode ^
      (reviewerName?.hashCode ?? 0) ^
      targetUserId.hashCode ^
      rating.hashCode ^
      (comment?.hashCode ?? 0) ^
      createdAt.hashCode;
}
