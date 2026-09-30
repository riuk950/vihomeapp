import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/presentation/widgets/review_list_item.dart';

void main() {
  group('ReviewListItem Widget', () {
    final testDate = DateTime(2026, 9, 30, 10, 0, 0);

    testWidgets('renders author name, stars, date and comment text', (tester) async {
      final review = Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'usr-1',
        reviewerName: 'Carlos Alberto Restrepo',
        targetUserId: 'usr-2',
        rating: 5,
        comment: 'Excelente experiencia durante todo el proceso de arriendo.',
        createdAt: testDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListItem(review: review),
          ),
        ),
      );

      expect(find.text('Carlos Alberto Restrepo'), findsOneWidget);
      expect(find.text('Excelente experiencia durante todo el proceso de arriendo.'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(5));
      expect(find.text('C'), findsOneWidget); // Avatar initial
    });

    testWidgets('renders gracefully when comment and reviewer name are absent', (tester) async {
      final review = Review(
        id: 'rev-2',
        solicitudId: 'sol-2',
        reviewerId: 'usr-anon',
        targetUserId: 'usr-2',
        rating: 4,
        comment: null,
        createdAt: testDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewListItem(review: review),
          ),
        ),
      );

      expect(find.text('Usuario'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    });
  });
}
