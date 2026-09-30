import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/pages/tenant/widgets/application_card_tenant.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';

class MockRatingTenantRepository implements ReviewRepository {
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
      id: 'rev-tenant-1',
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
}

void main() {
  late ReviewProvider reviewProvider;
  final now = DateTime.now();

  setUp(() {
    reviewProvider = ReviewProvider(MockRatingTenantRepository());
  });

  Widget buildTestCard(Application app) {
    return ChangeNotifierProvider<ReviewProvider>.value(
      value: reviewProvider,
      child: MaterialApp(
        home: Scaffold(
          body: ApplicationCardTenant(application: app),
        ),
      ),
    );
  }

  group('SolicitudesTenantRatingIntegration', () {
    testWidgets('shows "Calificar Propietario" button on accepted application and opens modal', (tester) async {
      final acceptedApp = Application(
        id: 'sol-accepted-tenant',
        arrendatarioId: 'usr-tenant-1',
        arrendadorId: 'usr-landlord-1',
        propiedadId: 'prop-1',
        estado: 'aceptada',
        nombreArrendador: 'Beatriz Salazar',
        tituloPropiedad: 'Apto 402',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestCard(acceptedApp));

      expect(find.text('Calificar Propietario'), findsOneWidget);

      await tester.tap(find.text('Calificar Propietario'));
      await tester.pumpAndSettle();

      expect(find.text('Calificar a Beatriz Salazar'), findsOneWidget);
    });

    testWidgets('hides "Calificar Propietario" button on pending and rejected applications', (tester) async {
      final pendingApp = Application(
        id: 'sol-pending-tenant',
        arrendatarioId: 'usr-tenant-1',
        arrendadorId: 'usr-landlord-1',
        propiedadId: 'prop-1',
        estado: 'pendiente',
        nombreArrendador: 'Beatriz Salazar',
        tituloPropiedad: 'Apto 402',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestCard(pendingApp));
      expect(find.text('Calificar Propietario'), findsNothing);

      final rejectedApp = Application(
        id: 'sol-rejected-tenant',
        arrendatarioId: 'usr-tenant-1',
        arrendadorId: 'usr-landlord-1',
        propiedadId: 'prop-1',
        estado: 'rechazada',
        nombreArrendador: 'Beatriz Salazar',
        tituloPropiedad: 'Apto 402',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestCard(rejectedApp));
      expect(find.text('Calificar Propietario'), findsNothing);
    });
  });
}
