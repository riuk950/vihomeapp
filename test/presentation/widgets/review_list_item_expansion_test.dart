import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/presentation/widgets/review_list_item.dart';

void main() {
  group('ReviewListItem Expansion Tests [RF-29.2, CL-28, QA-6]', () {
    final testDate = DateTime(2026, 9, 30, 10, 0, 0);

    testWidgets('short comment does NOT show Ver más button', (tester) async {
      final review = Review(
        id: 'rev-short',
        solicitudId: 'sol-1',
        reviewerId: 'usr-1',
        reviewerName: 'Ana María',
        targetUserId: 'usr-2',
        rating: 5,
        comment: 'Excelente arrendador, muy amable y puntual.',
        createdAt: testDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListItem(review: review),
          ),
        ),
      );

      expect(find.text('Ana María'), findsOneWidget);
      expect(find.text('Excelente arrendador, muy amable y puntual.'), findsOneWidget);
      expect(find.text('Ver más'), findsNothing);
      expect(find.text('Ver menos'), findsNothing);
    });

    testWidgets('long comment shows Ver más and toggles to Ver menos on tap', (tester) async {
      const longComment =
          'Este es un comentario sumamente extenso que supera los cien caracteres de longitud '
          'diseñado específicamente para validar el comportamiento del truncado y expansión en la interfaz '
          'de usuario móvil de ViHome.';

      final review = Review(
        id: 'rev-long',
        solicitudId: 'sol-2',
        reviewerId: 'usr-3',
        reviewerName: 'Felipe Morales',
        targetUserId: 'usr-2',
        rating: 4,
        comment: longComment,
        createdAt: testDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListItem(review: review),
          ),
        ),
      );

      // Ver más should be visible initially
      expect(find.text('Ver más'), findsOneWidget);
      expect(find.text('Ver menos'), findsNothing);

      // Tap "Ver más" to expand
      await tester.tap(find.text('Ver más'));
      await tester.pumpAndSettle();

      // Now "Ver menos" should be visible
      expect(find.text('Ver menos'), findsOneWidget);
      expect(find.text('Ver más'), findsNothing);

      // Tap "Ver menos" to collapse
      await tester.tap(find.text('Ver menos'));
      await tester.pumpAndSettle();

      // Back to "Ver más"
      expect(find.text('Ver más'), findsOneWidget);
      expect(find.text('Ver menos'), findsNothing);
    });
  });
}
