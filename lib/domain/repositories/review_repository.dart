import '../entities/review.dart';
import '../entities/user_reputation.dart';

/// Contrato del repositorio de calificaciones y reputación
abstract class ReviewRepository {
  /// Registra una nueva calificación inmutable vinculada a una solicitud completada
  Future<Review> createReview({
    required String solicitudId,
    required String reviewerId,
    required String targetUserId,
    required int rating,
    String? comment,
    String? reviewerName,
  });

  /// Obtiene la reputación calculada y consolidada de un usuario
  Future<UserReputation> getUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  });

  /// Obtiene la lista de calificaciones recibidas por un usuario
  Future<List<Review>> getUserReviews(String userId);

  /// Verifica si un usuario determinado tiene derecho a calificar una solicitud
  /// (la solicitud debe estar aprobada, no debe haber calificado antes y dentro del plazo de 60 días)
  Future<bool> canUserRateApplication({
    required String solicitudId,
    required String userId,
  });
}
