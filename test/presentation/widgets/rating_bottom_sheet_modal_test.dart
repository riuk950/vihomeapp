import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/widgets/rating_bottom_sheet_modal.dart';

class MockModalReviewRepository implements ReviewRepository {
  bool submitSuccess = true;
  Review? lastCreatedReview;

  @override
  Future<Review> createReview({
    required String solicitudId,
    required String reviewerId,
    required String targetUserId,
    required int rating,
    String? comment,
    String? reviewerName,
  }) async {
    if (!submitSuccess) {
      throw Exception('Fallo de red');
    }
    lastCreatedReview = Review(
      id: 'rev-modal-1',
      solicitudId: solicitudId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      targetUserId: targetUserId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    return lastCreatedReview!;
  }

  @override
  Future<UserReputation> getUserReputation(String userId, {bool isVerified = false, String? userName}) async {
    return UserReputation(userId: userId, isVerified: isVerified);
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async => [];

  @override
  Future<bool> canUserRateApplication({required String solicitudId, required String userId}) async => true;
}

void main() {
  late MockModalReviewRepository repository;
  late ReviewProvider reviewProvider;

  setUp(() {
    repository = MockModalReviewRepository();
    reviewProvider = ReviewProvider(repository);
  });

  Widget buildTestApp() {
    return ChangeNotifierProvider<ReviewProvider>.value(
      value: reviewProvider,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                RatingBottomSheetModal.show(
                  context,
                  solicitudId: 'sol-123',
                  reviewerId: 'usr-tenant',
                  reviewerName: 'Carlos',
                  targetUserId: 'usr-landlord',
                  targetUserName: 'Beatriz Salazar',
                  targetRoleTitle: 'Arrendador',
                );
              },
              child: const Text('Abrir Modal'),
            ),
          ),
        ),
      ),
    );
  }

  group('RatingBottomSheetModal Widget', () {
    testWidgets('opens modal, validates required stars and submits successfully', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Open modal
      await tester.tap(find.text('Abrir Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Calificar a Beatriz Salazar'), findsOneWidget);
      expect(find.text('Arrendador'), findsOneWidget);

      // Submit button should initially be disabled or show validation
      final submitButtonFinder = find.widgetWithText(ElevatedButton, 'Enviar Calificación');
      expect(submitButtonFinder, findsOneWidget);

      // Tap submit with 0 stars
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Debes seleccionar una puntuación obligatoria de 1 a 5 estrellas.'), findsOneWidget);
      expect(repository.lastCreatedReview, isNull);

      // Select 5 stars (5th IconButton)
      await tester.tap(find.byType(IconButton).at(4));
      await tester.pumpAndSettle();

      // Enter optional comment
      await tester.enterText(find.byType(TextField), 'Excelente arrendador, muy recomendado.');
      await tester.pumpAndSettle();

      expect(find.text('38/500'), findsOneWidget);

      // Submit again
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(repository.lastCreatedReview, isNotNull);
      expect(repository.lastCreatedReview!.rating, equals(5));
      expect(repository.lastCreatedReview!.comment, equals('Excelente arrendador, muy recomendado.'));
    });
  });
}
