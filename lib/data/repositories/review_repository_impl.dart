import '../../core/errors/review_exceptions.dart';
import '../../core/utils/comment_sanitizer.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/user_reputation.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';
import '../models/review_model.dart';

/// Implementación concreta de ReviewRepository
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Review> createReview({
    required String solicitudId,
    required String reviewerId,
    required String targetUserId,
    required int rating,
    String? comment,
    String? reviewerName,
  }) async {
    // 1. Validación de autocalificación (RF-23.3, CL-22)
    if (reviewerId == targetUserId) {
      throw const SelfRatingNotAllowedException();
    }

    // 2. Validación de rango de puntuación obligatoria (RF-24.1, RF-24.4)
    if (rating < 1 || rating > 5) {
      throw ReviewValidationException(
        'La puntuación debe ser un valor entero entre 1 y 5.',
      );
    }

    // 3. Sanitización de comentarios (RF-24.2, RF-24.5, CL-21, QA-13)
    final sanitizedComment = CommentSanitizer.sanitize(comment);

    // 4. Construcción del modelo de datos
    final reviewModel = ReviewModel(
      id: '', // Supabase generará el UUID
      solicitudId: solicitudId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      targetUserId: targetUserId,
      rating: rating,
      comment: sanitizedComment,
      createdAt: DateTime.now(),
    );

    // 5. Inserción remota y captura de excepciones
    return await remoteDataSource.insertReview(reviewModel);
  }

  @override
  Future<UserReputation> getUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async {
    return await remoteDataSource.fetchUserReputation(
      userId,
      isVerified: isVerified,
      userName: userName,
    );
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    return await remoteDataSource.fetchReviewsByTargetUser(userId);
  }

  @override
  Future<bool> canUserRateApplication({
    required String solicitudId,
    required String userId,
  }) async {
    final hasAlreadyRated = await remoteDataSource.hasUserRatedApplication(
      solicitudId: solicitudId,
      reviewerId: userId,
    );
    return !hasAlreadyRated;
  }
}
