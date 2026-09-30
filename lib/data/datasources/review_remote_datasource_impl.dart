import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/review_exceptions.dart';
import '../../infrastructure/services/supabase_service.dart';
import '../models/review_model.dart';
import '../models/user_reputation_model.dart';
import 'review_remote_datasource.dart';

/// Implementación remota de ReviewRemoteDataSource contra Supabase
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseService supabaseService;

  ReviewRemoteDataSourceImpl(this.supabaseService);

  SupabaseClient get _client => supabaseService.client;

  @override
  Future<ReviewModel> insertReview(ReviewModel review) async {
    try {
      final payload = {
        'solicitud_id': review.solicitudId,
        'reviewer_id': review.reviewerId,
        'reviewer_name': review.reviewerName,
        'target_user_id': review.targetUserId,
        'rating': review.rating,
        'comment': review.comment,
      };

      final response = await _client
          .from('reviews')
          .insert(payload)
          .select()
          .single();

      return ReviewModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AlreadyRatedException();
      }
      if (e.code == '23514') {
        throw ReviewValidationException(
          'Error de validación en la calificación: ${e.message}',
        );
      }
      throw ReviewValidationException('Error al guardar la calificación: ${e.message}');
    } on AuthException catch (e) {
      throw SessionExpiredRatingException(
        'Tu sesión ha expirado: ${e.message}',
      );
    } catch (e) {
      if (e is ReviewException) rethrow;
      throw ReviewValidationException('Error inesperado al emitir calificación: $e');
    }
  }

  @override
  Future<List<ReviewModel>> fetchReviewsByTargetUser(String targetUserId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('target_user_id', targetUserId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<UserReputationModel> fetchUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async {
    try {
      final reviews = await fetchReviewsByTargetUser(userId);

      if (reviews.isEmpty) {
        return UserReputationModel(
          userId: userId,
          userName: userName,
          isVerified: isVerified,
          averageRating: null,
          totalReviews: 0,
        );
      }

      final sum = reviews.fold<int>(0, (prev, r) => prev + r.rating);
      final rawAvg = sum / reviews.length;

      return UserReputationModel(
        userId: userId,
        userName: userName,
        isVerified: isVerified,
        averageRating: rawAvg,
        totalReviews: reviews.length,
      );
    } catch (e) {
      return UserReputationModel(
        userId: userId,
        userName: userName,
        isVerified: isVerified,
        averageRating: null,
        totalReviews: 0,
      );
    }
  }

  @override
  Future<bool> hasUserRatedApplication({
    required String solicitudId,
    required String reviewerId,
  }) async {
    try {
      final response = await _client
          .from('reviews')
          .select('id')
          .eq('solicitud_id', solicitudId)
          .eq('reviewer_id', reviewerId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
