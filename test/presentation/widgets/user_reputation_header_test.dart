import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/presentation/widgets/user_reputation_header.dart';

void main() {
  group('UserReputationHeader and ReviewsListWidget', () {
    testWidgets('renders established reputation header with verified badge and reviews', (tester) async {
      final rep = UserReputation(
        userId: 'usr-landlord-1',
        userName: 'Beatriz Salazar',
        isVerified: true,
        averageRating: 4.8,
        totalReviews: 2,
      );

      final reviews = [
        Review(
          id: 'rev-1',
          solicitudId: 'sol-1',
          reviewerId: 'usr-t1',
          reviewerName: 'Carlos Restrepo',
          targetUserId: 'usr-landlord-1',
          rating: 5,
          comment: 'Excelente arrendador',
          createdAt: DateTime(2026, 9, 29),
        ),
        Review(
          id: 'rev-2',
          solicitudId: 'sol-2',
          reviewerId: 'usr-t2',
          reviewerName: 'Ana María Gómez',
          targetUserId: 'usr-landlord-1',
          rating: 4,
          comment: 'Todo muy claro y a tiempo',
          createdAt: DateTime(2026, 9, 28),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  UserReputationHeader(reputation: rep),
                  UserReviewsListWidget(reviews: reviews),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('Basado en 2 reseñas'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Carlos Restrepo'), findsOneWidget);
      expect(find.text('Ana María Gómez'), findsOneWidget);
    });

    testWidgets('renders initial trust score (3.0 ★) for verified user without reviews', (tester) async {
      final rep = UserReputation(
        userId: 'usr-ver-new',
        userName: 'Nuevo Usuario',
        isVerified: true,
        averageRating: null,
        totalReviews: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserReputationHeader(reputation: rep),
          ),
        ),
      );

      expect(find.text('3.0'), findsOneWidget);
      expect(find.text('Puntaje inicial de confianza'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('renders neutral status for unverified user without reviews', (tester) async {
      final rep = UserReputation(
        userId: 'usr-anon',
        isVerified: false,
        averageRating: null,
        totalReviews: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                UserReputationHeader(reputation: rep),
                const UserReviewsListWidget(reviews: []),
              ],
            ),
          ),
        ),
      );

      expect(find.text('—'), findsOneWidget);
      expect(find.text('Sin calificaciones aún'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsNothing);
      expect(find.text('Aún no se han recibido opiniones.'), findsOneWidget);
    });
  });
}
