import 'package:flutter/material.dart';
import '../../domain/entities/user_reputation.dart';

/// Insignia compacta de reputación para tarjetas de inmuebles, anuncios y mapas
class RatingBadge extends StatelessWidget {
  final UserReputation reputation;
  final String? prefix;
  final double fontSize;
  final Color starColor;

  const RatingBadge({
    super.key,
    required this.reputation,
    this.prefix,
    this.fontSize = 12.0,
    this.starColor = const Color(0xFFF59E0B),
  });

  @override
  Widget build(BuildContext context) {
    final String textToDisplay;
    final bool showStar;

    if (reputation.totalReviews == 0) {
      if (reputation.isVerified) {
        textToDisplay = prefix != null
            ? '$prefix: 3.0 ★ (Inicial)'
            : '3.0 ★ (Inicial)';
        showStar = true;
      } else {
        textToDisplay = prefix != null
            ? '$prefix: Sin calificaciones'
            : 'Sin calificaciones';
        showStar = false;
      }
    } else {
      final ratingStr = reputation.formattedRating;
      final count = reputation.totalReviews;
      textToDisplay = prefix != null
          ? '$prefix: $ratingStr ★ ($count)'
          : '$ratingStr ★ ($count)';
      showStar = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: showStar
            ? const Color(0xFFFEF3C7) // Ámbar muy suave
            : const Color(0xFFF3F4F6), // Gris suave
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: showStar
              ? const Color(0xFFFDE68A)
              : const Color(0xFFE5E7EB),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStar) ...[
            Icon(
              Icons.star,
              size: fontSize + 2.0,
              color: starColor,
            ),
            const SizedBox(width: 4.0),
          ],
          Text(
            textToDisplay,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: showStar
                  ? const Color(0xFF92400E) // Ámbar oscuro legible
                  : const Color(0xFF4B5563), // Gris legible
            ),
          ),
        ],
      ),
    );
  }
}
