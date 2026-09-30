import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/presentation/widgets/rating_stars_bar.dart';

void main() {
  group('RatingStarsBar Widget', () {
    testWidgets('renders 5 stars and allows selection in interactive mode', (tester) async {
      int selectedRating = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsBar(
              rating: selectedRating,
              isInteractive: true,
              onRatingChanged: (value) {
                selectedRating = value;
              },
            ),
          ),
        ),
      );

      // Verify 5 star icons are present
      expect(find.byType(IconButton), findsNWidgets(5));

      // Tap on 4th star
      await tester.tap(find.byType(IconButton).at(3));
      await tester.pumpAndSettle();

      expect(selectedRating, equals(4));
    });

    testWidgets('displays read-only stars without interactive callbacks', (tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsBar(
              rating: 3,
              isInteractive: false,
              onRatingChanged: (_) {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // In read-only mode, it should render icons without IconButtons
      expect(find.byType(IconButton), findsNothing);
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.star).first);
      await tester.pumpAndSettle();

      expect(wasTapped, isFalse);
    });

    testWidgets('provides accessible semantic labels for screen readers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsBar(
              rating: 4,
              isInteractive: true,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Calificar con 1 de 5 estrellas'), findsOneWidget);
      expect(find.bySemanticsLabel('Calificar con 4 de 5 estrellas'), findsOneWidget);
      expect(find.bySemanticsLabel('Calificar con 5 de 5 estrellas'), findsOneWidget);
    });
  });
}
