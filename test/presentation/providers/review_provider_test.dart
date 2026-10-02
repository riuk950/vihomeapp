import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/review_exceptions.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';

class MockReviewRepository implements ReviewRepository {
  bool shouldThrowNetwork = false;
  bool shouldThrowAlreadyRated = false;
  final List<Review> createdReviews = [];

  @override
  Future<Review> createReview({
    required String solicitudId,
    required String reviewerId,
    required String targetUserId,
    required int rating,
    String? comment,
    String? reviewerName,
  }) async {
    if (shouldThrowNetwork) {
      throw Exception('Fallo de conexión');
    }
    if (shouldThrowAlreadyRated) {
      throw const AlreadyRatedException();
    }
    final review = Review(
      id: 'rev-${createdReviews.length + 1}',
      solicitudId: solicitudId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      targetUserId: targetUserId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    createdReviews.add(review);
    return review;
  }

  @override
  Future<UserReputation> getUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async {
    final userReviews = createdReviews.where((r) => r.targetUserId == userId).toList();
    if (userReviews.isEmpty) {
      return UserReputation(
        userId: userId,
        userName: userName,
        isVerified: isVerified,
        averageRating: null,
        totalReviews: 0,
      );
    }
    final sum = userReviews.fold<int>(0, (prev, r) => prev + r.rating);
    return UserReputation(
      userId: userId,
      userName: userName,
      isVerified: isVerified,
      averageRating: sum / userReviews.length,
      totalReviews: userReviews.length,
    );
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    return createdReviews.where((r) => r.targetUserId == userId).toList();
  }

  @override
  Future<bool> canUserRateApplication({
    required String solicitudId,
    required String userId,
  }) async {
    final already = createdReviews.any(
      (r) => r.solicitudId == solicitudId && r.reviewerId == userId,
    );
    return !already;
  }

  @override
  Future<Review> registerVerifiedUserReview({
    required String userId,
    String? userName,
  }) async {
    final existing = createdReviews.cast<Review?>().firstWhere(
      (r) => r?.solicitudId == null && r?.targetUserId == userId,
      orElse: () => null,
    );
    if (existing != null) return existing;

    final review = Review(
      id: 'rev-verified-${createdReviews.length + 1}',
      solicitudId: null,
      reviewerId: userId,
      reviewerName: userName ?? 'Sistema ViHome',
      targetUserId: userId,
      rating: 3,
      comment: 'Usuario verificado',
      createdAt: DateTime.now(),
    );
    createdReviews.add(review);
    return review;
  }
}

void main() {
  late MockReviewRepository repository;
  late ReviewProvider provider;

  setUp(() {
    repository = MockReviewRepository();
    provider = ReviewProvider(repository);
  });

  group('ReviewProvider', () {
    test('submits review successfully and notifies listeners', () async {
      var listenerCalls = 0;
      provider.addListener(() => listenerCalls++);

      final success = await provider.submitReview(
        solicitudId: 'sol-1',
        reviewerId: 'usr-tenant',
        reviewerName: 'Carlos',
        targetUserId: 'usr-landlord',
        rating: 5,
        comment: 'Muy buena experiencia',
      );

      expect(success, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(listenerCalls, greaterThanOrEqualTo(2));
      expect(repository.createdReviews.length, equals(1));
    });

    test('validates rating is between 1 and 5 and rejects 0 without repository call', () async {
      final success = await provider.submitReview(
        solicitudId: 'sol-1',
        reviewerId: 'usr-tenant',
        targetUserId: 'usr-landlord',
        rating: 0,
      );

      expect(success, isFalse);
      expect(provider.errorMessage, contains('Debes seleccionar una puntuación'));
      expect(repository.createdReviews.isEmpty, isTrue);
    });

    test('preserves draft comment and rating upon error for retry', () async {
      repository.shouldThrowNetwork = true;

      final success = await provider.submitReview(
        solicitudId: 'sol-1',
        reviewerId: 'usr-tenant',
        targetUserId: 'usr-landlord',
        rating: 4,
        comment: 'Texto importante que no debe perderse',
      );

      expect(success, isFalse);
      expect(provider.draftRating, equals(4));
      expect(provider.draftComment, equals('Texto importante que no debe perderse'));
      expect(provider.errorMessage, isNotNull);
    });

    test('prevents concurrent double submissions while loading', () async {
      // Trigger two submissions in parallel
      final future1 = provider.submitReview(
        solicitudId: 'sol-1',
        reviewerId: 'usr-tenant',
        targetUserId: 'usr-landlord',
        rating: 5,
      );
      final future2 = provider.submitReview(
        solicitudId: 'sol-1',
        reviewerId: 'usr-tenant',
        targetUserId: 'usr-landlord',
        rating: 5,
      );

      final results = await Future.wait([future1, future2]);
      // One succeeds, one is rejected/ignored due to concurrent lock
      expect(repository.createdReviews.length, equals(1));
      expect(results.contains(true), isTrue);
    });

    test('fetches user reputation and updates cache', () async {
      final rep = await provider.fetchUserReputation(
        'usr-landlord',
        isVerified: true,
        userName: 'Beatriz',
      );

      expect(rep.userId, equals('usr-landlord'));
      expect(rep.isVerified, isTrue);
      expect(provider.getReputationFor('usr-landlord'), equals(rep));
    });

    test('registerVerifiedUserReview registers review and updates cached reputation and reviews', () async {
      await provider.registerVerifiedUserReview(
        userId: 'usr-new-user',
        userName: 'Elena Gómez',
      );

      expect(repository.createdReviews.length, equals(1));
      expect(repository.createdReviews.first.rating, equals(3));
      expect(repository.createdReviews.first.comment, equals('Usuario verificado'));

      final rep = provider.getReputationFor('usr-new-user');
      expect(rep, isNotNull);
      expect(rep!.isVerified, isTrue);
      expect(rep.averageRating, equals(3.0));

      final reviews = provider.getReviewsFor('usr-new-user');
      expect(reviews, isNotNull);
      expect(reviews!.length, equals(1));
      expect(reviews.first.comment, equals('Usuario verificado'));
    });
  });
}
