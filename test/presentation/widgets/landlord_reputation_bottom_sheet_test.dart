import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/presentation/widgets/landlord_reputation_bottom_sheet.dart';

void main() {
  group('LandlordReputationBottomSheet Tests [RF-30.3, RF-32.1, RF-33.1, QA-1, QA-3]', () {
    final rep = UserReputation(
      userId: 'usr-landlord-1',
      averageRating: 4.8,
      totalReviews: 2,
      isVerified: true,
    );

    final reviews = [
      Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'usr-tenant-1',
        reviewerName: 'Juliana Restrepo',
        targetUserId: 'usr-landlord-1',
        rating: 5,
        comment: 'Excelente arrendador, cumplió con todas las condiciones.',
        createdAt: DateTime(2026, 9, 20),
      ),
      Review(
        id: 'rev-2',
        solicitudId: 'sol-2',
        reviewerId: 'usr-tenant-2',
        reviewerName: 'Esteban Valencia',
        targetUserId: 'usr-landlord-1',
        rating: 4,
        comment: 'Buena comunicación.',
        createdAt: DateTime(2026, 9, 15),
      ),
    ];

    testWidgets('renders landlord reputation header, review count and list items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LandlordReputationBottomSheet(
              landlordName: 'Don Rodrigo Arango',
              reputation: rep,
              reviews: reviews,
            ),
          ),
        ),
      );

      expect(find.text('Reputación del Arrendador'), findsOneWidget);
      expect(find.text('Don Rodrigo Arango'), findsOneWidget);
      expect(find.text('Reseñas de Inquilinos'), findsOneWidget);
      expect(find.text('2 opiniones'), findsOneWidget);

      expect(find.text('Juliana Restrepo'), findsOneWidget);
      expect(find.text('Excelente arrendador, cumplió con todas las condiciones.'), findsOneWidget);
      expect(find.text('Esteban Valencia'), findsOneWidget);
      expect(find.text('Buena comunicación.'), findsOneWidget);
    });

    testWidgets('renders friendly empty state when landlord has zero reviews', (tester) async {
      final emptyRep = UserReputation(
        userId: 'usr-landlord-empty',
        averageRating: null,
        totalReviews: 0,
        isVerified: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LandlordReputationBottomSheet(
              landlordName: 'Nuevo Propietario',
              reputation: emptyRep,
              reviews: const [],
            ),
          ),
        ),
      );

      expect(find.text('Nuevo Propietario'), findsOneWidget);
      expect(find.text('0 opiniones'), findsOneWidget);
      expect(
        find.text('El arrendador aún no cuenta con reseñas de inquilinos.'),
        findsOneWidget,
      );
    });

    testWidgets('modal can be opened and closed using static show helper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  LandlordReputationBottomSheet.show(
                    context,
                    landlordName: 'Don Rodrigo',
                    reputation: rep,
                    reviews: reviews,
                  );
                },
                child: const Text('Abrir Modal'),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Abrir Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Reputación del Arrendador'), findsOneWidget);
      expect(find.text('Don Rodrigo'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Reputación del Arrendador'), findsNothing);
    });
  });
}
