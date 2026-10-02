import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vihomeapp/data/datasources/review_remote_datasource.dart';
import 'package:vihomeapp/data/models/review_model.dart';
import 'package:vihomeapp/data/models/user_reputation_model.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/data/repositories/review_repository_impl.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';

class DummyReviewRemoteDataSource implements ReviewRemoteDataSource {
  @override
  Future<ReviewModel> insertReview(ReviewModel review) async => review;

  @override
  Future<List<ReviewModel>> fetchReviewsByTargetUser(String targetUserId) async => [];

  @override
  Future<UserReputationModel> fetchUserReputation(String userId, {bool isVerified = false, String? userName}) async {
    return UserReputationModel(userId: userId, isVerified: isVerified);
  }

  @override
  Future<bool> hasUserRatedApplication({required String solicitudId, required String reviewerId}) async => false;

  @override
  Future<ReviewModel> registerVerifiedUserReview({required String userId, String? userName}) async {
    return ReviewModel(
      id: 'rev-dummy',
      solicitudId: null,
      reviewerId: userId,
      reviewerName: userName,
      targetUserId: userId,
      rating: 3,
      comment: 'Usuario verificado',
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  final sl = GetIt.asNewInstance();

  setUp(() {
    sl.registerLazySingleton<ReviewRemoteDataSource>(
      () => DummyReviewRemoteDataSource(),
    );
    sl.registerLazySingleton<ReviewRepository>(
      () => ReviewRepositoryImpl(sl<ReviewRemoteDataSource>()),
    );
    sl.registerFactory(
      () => ReviewProvider(sl<ReviewRepository>()),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  group('Review DI Registration', () {
    test('resolves ReviewRemoteDataSource, ReviewRepository and ReviewProvider', () {
      expect(sl.isRegistered<ReviewRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<ReviewRepository>(), isTrue);
      expect(sl.isRegistered<ReviewProvider>(), isTrue);

      final repo = sl<ReviewRepository>();
      expect(repo, isA<ReviewRepository>());

      final provider1 = sl<ReviewProvider>();
      final provider2 = sl<ReviewProvider>();
      // Factory creates a new instance each time
      expect(provider1, isA<ReviewProvider>());
      expect(identical(provider1, provider2), isFalse);
    });
  });
}
