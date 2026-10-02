import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/pages/landlord/widgets/application_card_landlord.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';

class MockRatingLandlordRepository implements ReviewRepository {
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
      id: 'rev-landlord-1',
      solicitudId: solicitudId,
      reviewerId: reviewerId,
      targetUserId: targetUserId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserReputation> getUserReputation(String userId, {bool isVerified = false, String? userName}) async =>
      UserReputation(userId: userId, isVerified: isVerified);

  @override
  Future<List<Review>> getUserReviews(String userId) async => [];

  @override
  Future<bool> canUserRateApplication({required String solicitudId, required String userId}) async => true;

  @override
  Future<Review> registerVerifiedUserReview({required String userId, String? userName}) async =>
      Review(
        id: 'rev-verified',
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
  late ReviewProvider reviewProvider;
  final now = DateTime.now();

  setUp(() {
    reviewProvider = ReviewProvider(MockRatingLandlordRepository());
  });

  Widget buildTestCard(Application app) {
    return ChangeNotifierProvider<ReviewProvider>.value(
      value: reviewProvider,
      child: MaterialApp(
        home: Scaffold(
          body: ApplicationCardLandlord(application: app),
        ),
      ),
    );
  }

  group('SolicitudesLandlordRatingIntegration', () {
    testWidgets('shows "Calificar Postulante" button on accepted application and opens modal', (tester) async {
      final acceptedApp = Application(
        id: 'sol-accepted',
        arrendatarioId: 'usr-tenant-1',
        arrendadorId: 'usr-landlord-1',
        propiedadId: 'prop-1',
        estado: 'aceptada',
        nombreArrendatario: 'Carlos Restrepo',
        tituloPropiedad: 'Apto 402',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestCard(acceptedApp));

      expect(find.text('Calificar Postulante'), findsOneWidget);

      await tester.tap(find.text('Calificar Postulante'));
      await tester.pumpAndSettle();

      expect(find.text('Calificar a Carlos Restrepo'), findsOneWidget);
    });

    testWidgets('hides "Calificar Postulante" button on pending and rejected applications', (tester) async {
      final pendingApp = Application(
        id: 'sol-pending',
        arrendatarioId: 'usr-tenant-1',
        arrendadorId: 'usr-landlord-1',
        propiedadId: 'prop-1',
        estado: 'pendiente',
        nombreArrendatario: 'Carlos Restrepo',
        tituloPropiedad: 'Apto 402',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestCard(pendingApp));
      expect(find.text('Calificar Postulante'), findsNothing);

      final rejectedApp = Application(
        id: 'sol-rejected',
        arrendatarioId: 'usr-tenant-1',
        arrendadorId: 'usr-landlord-1',
        propiedadId: 'prop-1',
        estado: 'rechazada',
        nombreArrendatario: 'Carlos Restrepo',
        tituloPropiedad: 'Apto 402',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestCard(rejectedApp));
      expect(find.text('Calificar Postulante'), findsNothing);
    });
  });
}
