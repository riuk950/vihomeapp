import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/presentation/widgets/rating_badge.dart';

void main() {
  group('RatingBadge Widget', () {
    testWidgets('renders rating and total count for established reputation', (tester) async {
      final rep = UserReputation(
        userId: 'usr-landlord-1',
        averageRating: 4.8,
        totalReviews: 15,
        isVerified: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingBadge(
              reputation: rep,
              prefix: 'Propietario',
            ),
          ),
        ),
      );

      expect(find.text('Propietario: 4.8 ★ (15)'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders neutral label for unverified user with zero reviews', (tester) async {
      final rep = UserReputation(
        userId: 'usr-new',
        averageRating: null,
        totalReviews: 0,
        isVerified: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingBadge(reputation: rep),
          ),
        ),
      );

      expect(find.text('Sin calificaciones'), findsOneWidget);
    });

    testWidgets('renders provisional label for verified user with zero reviews', (tester) async {
      final rep = UserReputation(
        userId: 'usr-verified-new',
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

      expect(find.text('3.0 ★ (Inicial)'), findsOneWidget);
    });
  });
}
