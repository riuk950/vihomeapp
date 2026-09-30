import '../models/review_model.dart';
import '../models/user_reputation_model.dart';

/// Interfaz abstracta para operaciones remotas de calificaciones y reputación
abstract class ReviewRemoteDataSource {
  /// Inserta una calificación en Supabase
  Future<ReviewModel> insertReview(ReviewModel review);

  /// Recupera todas las calificaciones recibidas por un usuario
  Future<List<ReviewModel>> fetchReviewsByTargetUser(String targetUserId);

  /// Obtiene o calcula la reputación de un usuario a partir de sus calificaciones
  Future<UserReputationModel> fetchUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  });

  /// Verifica si el usuario ya registró una calificación para la solicitud indicada
  Future<bool> hasUserRatedApplication({
    required String solicitudId,
    required String reviewerId,
  });
}
