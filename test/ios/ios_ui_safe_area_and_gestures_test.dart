import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/widgets/rating_bottom_sheet_modal.dart';
import 'package:vihomeapp/presentation/widgets/landlord_reputation_bottom_sheet.dart';

class MockReviewRepositoryForIos implements ReviewRepository {
  @override
  Future<Review> createReview({
    required String solicitudId,
    required String reviewerId,
    required String targetUserId,
    required int rating,
    String? comment,
    String? reviewerName,
  }) async {
    return Review(
      id: 'rev-ios-1',
      solicitudId: solicitudId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      targetUserId: targetUserId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserReputation> getUserReputation(String userId,
      {bool isVerified = false, String? userName}) async {
    return UserReputation(userId: userId, isVerified: isVerified);
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async => [];

  @override
  Future<bool> canUserRateApplication(
          {required String solicitudId, required String userId}) async =>
      true;

  @override
  Future<Review> registerVerifiedUserReview(
          {required String userId, String? userName}) async =>
      Review(
        id: 'rev-ver-ios',
        solicitudId: null,
        reviewerId: userId,
        reviewerName: userName,
        targetUserId: userId,
        rating: 3,
        comment: 'Usuario verificado',
        createdAt: DateTime.now(),
      );
}

void main() {
  group('iOS Platform UX & Safe Area Tests', () {
    testWidgets(
        'RatingBottomSheetModal respects iOS Home Indicator inset (34pt) without layout overflow',
        (tester) async {
      final mockRepo = MockReviewRepositoryForIos();
      final reviewProvider = ReviewProvider(mockRepo);

      await tester.pumpWidget(
        ChangeNotifierProvider<ReviewProvider>.value(
          value: reviewProvider,
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(393, 852), // iPhone 15/16 screen size
                padding: EdgeInsets.only(top: 59, bottom: 34), // Dynamic Island & Home Indicator
                viewPadding: EdgeInsets.only(top: 59, bottom: 34),
              ),
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          RatingBottomSheetModal.show(
                            context,
                            solicitudId: 'sol-1',
                            reviewerId: 'user-1',
                            targetUserId: 'target-1',
                            targetUserName: 'Carlos Propietario',
                          );
                        },
                        child: const Text('Calificar'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Calificar'));
      await tester.pumpAndSettle();

      // Verify modal is displayed
      expect(find.text('Calificar a Carlos Propietario'), findsOneWidget);

      // Verify no overflow errors were thrown during iOS layout
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'LandlordReputationBottomSheet displays properly inside iOS SafeArea without clipping',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(393, 852),
              padding: EdgeInsets.only(top: 59, bottom: 34),
              viewPadding: EdgeInsets.only(top: 59, bottom: 34),
            ),
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        LandlordReputationBottomSheet.show(
                          context,
                          landlordName: 'María Gomez',
                          reputation: const UserReputation(
                            userId: 'landlord-1',
                            averageRating: 4.8,
                            totalReviews: 12,
                            isVerified: true,
                          ),
                        );
                      },
                      child: const Text('Ver Reputación'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Open reputation bottom sheet
      await tester.tap(find.text('Ver Reputación'));
      await tester.pumpAndSettle();

      expect(find.text('Reputación del Arrendador'), findsOneWidget);
      expect(find.text('María Gomez'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
