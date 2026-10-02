import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/review_exceptions.dart';
import 'package:vihomeapp/data/datasources/review_remote_datasource.dart';
import 'package:vihomeapp/data/models/review_model.dart';
import 'package:vihomeapp/data/models/user_reputation_model.dart';
import 'package:vihomeapp/data/repositories/review_repository_impl.dart';

class FakeReviewRemoteDataSource implements ReviewRemoteDataSource {
  final List<ReviewModel> _storedReviews = [];
  bool shouldThrowNetworkError = false;
  bool shouldThrowAlreadyRated = false;

  @override
  Future<ReviewModel> insertReview(ReviewModel review) async {
    if (shouldThrowNetworkError) {
      throw Exception('Network connection failed');
    }
    if (shouldThrowAlreadyRated) {
      throw const AlreadyRatedException();
    }
    _storedReviews.add(review);
    return review;
  }

  @override
  Future<List<ReviewModel>> fetchReviewsByTargetUser(String targetUserId) async {
    if (shouldThrowNetworkError) {
      throw Exception('Network error');
    }
    return _storedReviews.where((r) => r.targetUserId == targetUserId).toList();
  }

  @override
  Future<UserReputationModel> fetchUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async {
    final userReviews = await fetchReviewsByTargetUser(userId);
    if (userReviews.isEmpty) {
      return UserReputationModel(
        userId: userId,
        userName: userName,
        isVerified: isVerified,
        averageRating: null,
        totalReviews: 0,
      );
    }
    final sum = userReviews.fold<int>(0, (prev, r) => prev + r.rating);
    final avg = sum / userReviews.length;
    return UserReputationModel(
      userId: userId,
      userName: userName,
      isVerified: isVerified,
      averageRating: avg,
      totalReviews: userReviews.length,
    );
  }

  @override
  Future<bool> hasUserRatedApplication({
    required String solicitudId,
    required String reviewerId,
  }) async {
    return _storedReviews.any(
      (r) => r.solicitudId == solicitudId && r.reviewerId == reviewerId,
    );
  }

  @override
  Future<ReviewModel> registerVerifiedUserReview({
    required String userId,
    String? userName,
  }) async {
    if (shouldThrowNetworkError) {
      throw Exception('Network error');
    }
    final existing = _storedReviews.cast<ReviewModel?>().firstWhere(
      (r) => r?.solicitudId == null && r?.targetUserId == userId,
      orElse: () => null,
    );
    if (existing != null) return existing;

    final review = ReviewModel(
      id: 'rev-verified-${_storedReviews.length + 1}',
      solicitudId: null,
      reviewerId: userId,
      reviewerName: userName ?? 'Sistema ViHome',
      targetUserId: userId,
      rating: 3,
      comment: 'Usuario verificado',
      createdAt: DateTime.now(),
    );
    _storedReviews.add(review);
    return review;
  }
}

void main() {
  late FakeReviewRemoteDataSource fakeDataSource;
  late ReviewRepositoryImpl repository;

  setUp(() {
    fakeDataSource = FakeReviewRemoteDataSource();
    repository = ReviewRepositoryImpl(fakeDataSource);
  });

  group('ReviewRepositoryImpl', () {
    test('creates review successfully with sanitized comment', () async {
      final review = await repository.createReview(
        solicitudId: 'sol-1',
        reviewerId: 'usr-tenant',
        reviewerName: 'Carlos',
        targetUserId: 'usr-landlord',
        rating: 5,
        comment: '  Excelente arrendador. \n\n\n\n Muy atento.  ',
      );

      expect(review.rating, equals(5));
      expect(review.comment, equals('Excelente arrendador. \n\n Muy atento.'));
      expect(review.reviewerId, equals('usr-tenant'));
      expect(review.targetUserId, equals('usr-landlord'));
    });

    test('throws SelfRatingNotAllowedException before datasource call', () async {
      expect(
        () => repository.createReview(
          solicitudId: 'sol-1',
          reviewerId: 'usr-same',
          targetUserId: 'usr-same',
          rating: 5,
        ),
        throwsA(isA<SelfRatingNotAllowedException>()),
      );
    });

    test('throws ReviewValidationException when rating is invalid', () async {
      expect(
        () => repository.createReview(
          solicitudId: 'sol-1',
          reviewerId: 'usr-1',
          targetUserId: 'usr-2',
          rating: 0,
        ),
        throwsA(isA<ReviewValidationException>()),
      );
    });

    test('propagates AlreadyRatedException from datasource', () async {
      fakeDataSource.shouldThrowAlreadyRated = true;

      expect(
        () => repository.createReview(
          solicitudId: 'sol-1',
          reviewerId: 'usr-tenant',
          targetUserId: 'usr-landlord',
          rating: 4,
        ),
        throwsA(isA<AlreadyRatedException>()),
      );
    });

    test('calculates user reputation accurately from datasource', () async {
      await repository.createReview(
        solicitudId: 'sol-1',
        reviewerId: 'usr-tenant-1',
        targetUserId: 'usr-landlord',
        rating: 5,
      );
      await repository.createReview(
        solicitudId: 'sol-2',
        reviewerId: 'usr-tenant-2',
        targetUserId: 'usr-landlord',
        rating: 4,
      );

      final reputation = await repository.getUserReputation(
        'usr-landlord',
        isVerified: true,
        userName: 'Beatriz Salazar',
      );

      expect(reputation.totalReviews, equals(2));
      expect(reputation.displayRating, equals(4.5));
      expect(reputation.hasRealRatings, isTrue);
      expect(reputation.statusLabel, equals('Basado en 2 reseñas'));
    });

    test('canUserRateApplication returns false if already rated', () async {
      await repository.createReview(
        solicitudId: 'sol-100',
        reviewerId: 'usr-1',
        targetUserId: 'usr-2',
        rating: 5,
      );

      final canRate = await repository.canUserRateApplication(
        solicitudId: 'sol-100',
        userId: 'usr-1',
      );

      expect(canRate, isFalse);

      final canOtherUserRate = await repository.canUserRateApplication(
        solicitudId: 'sol-100',
        userId: 'usr-2',
      );

      expect(canOtherUserRate, isTrue);
    });

    test('registerVerifiedUserReview creates initial 3-star verified review with idempotency', () async {
      final review1 = await repository.registerVerifiedUserReview(
        userId: 'usr-new-landlord',
        userName: 'Carlos Arrendador',
      );

      expect(review1.rating, equals(3));
      expect(review1.comment, equals('Usuario verificado'));
      expect(review1.solicitudId, isNull);
      expect(review1.targetUserId, equals('usr-new-landlord'));

      // Invocación subsiguiente (idempotencia)
      final review2 = await repository.registerVerifiedUserReview(
        userId: 'usr-new-landlord',
        userName: 'Carlos Arrendador',
      );

      expect(review2.id, equals(review1.id));
      expect(review2.rating, equals(3));
    });
  });
}
