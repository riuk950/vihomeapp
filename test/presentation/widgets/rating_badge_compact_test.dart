import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/presentation/widgets/rating_badge.dart';

void main() {
  group('RatingBadge Compact & Semantics Tests [RF-31.2, CL-24, RNF-20, RNF-21, QA-8]', () {
    testWidgets('renders accessible semantics label for established reputation', (tester) async {
      final handle = tester.ensureSemantics();
      final rep = UserReputation(
        userId: 'usr-1',
        averageRating: 4.8,
        totalReviews: 12,
        isVerified: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingBadge(reputation: rep),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Calificación: 4.8 de 5 estrellas basado en 12 reseñas'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('renders accessible semantics label for provisional verified user', (tester) async {
      final handle = tester.ensureSemantics();
      final rep = UserReputation(
        userId: 'usr-verified',
        averageRating: null,
        totalReviews: 0,
        isVerified: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingBadge(reputation: rep),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Calificación inicial de confianza: 3.0 de 5 estrellas'),
        findsOneWidget,
      );
      expect(find.text('3.0 ★ (Inicial)'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('adapts smoothly without overflow in narrow 320 px container [RNF-21]', (tester) async {
      final rep = UserReputation(
        userId: 'usr-narrow',
        averageRating: 4.9,
        totalReviews: 120,
        isVerified: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: Row(
                  children: [
                    const Text('Anfitrión: '),
                    Expanded(
                      child: RatingBadge(
                        reputation: rep,
                        prefix: 'Propietario Destacado',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Verify no RenderFlex overflow exception
      expect(tester.takeException(), isNull);
    });
  });
}
