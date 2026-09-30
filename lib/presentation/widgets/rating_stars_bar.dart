import 'package:flutter/material.dart';

/// Barra interactiva o de solo lectura para calificación por estrellas (1 a 5).
/// Cumple con las directrices de accesibilidad semántica WCAG 2.1 AA.
class RatingStarsBar extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double starSize;
  final Color starColor;
  final Color emptyColor;
  final bool isInteractive;
  final ValueChanged<int>? onRatingChanged;

  const RatingStarsBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.starSize = 32.0,
    this.starColor = const Color(0xFFF59E0B), // Ámbar dorado
    this.emptyColor = const Color(0xFFD1D5DB), // Gris claro
    this.isInteractive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;

        if (isInteractive) {
          return Semantics(
            label: 'Calificar con $starValue de $maxRating estrellas',
            button: true,
            selected: isFilled,
            child: IconButton(
              iconSize: starSize,
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              constraints: const BoxConstraints(),
              icon: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? starColor : emptyColor,
              ),
              onPressed: () {
                if (onRatingChanged != null) {
                  onRatingChanged!(starValue);
                }
              },
            ),
          );
        }

        return Semantics(
          label: isFilled
              ? 'Estrella $starValue activa'
              : 'Estrella $starValue inactiva',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: starSize,
              color: isFilled ? starColor : emptyColor,
            ),
          ),
        );
      }),
    );
  }
}
