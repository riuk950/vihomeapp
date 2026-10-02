import 'package:flutter/material.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/user_reputation.dart';
import 'rating_stars_bar.dart';
import 'review_list_item.dart';

/// Encabezado visual de reputación y confianza para perfiles de usuario
class UserReputationHeader extends StatelessWidget {
  final UserReputation reputation;

  const UserReputationHeader({
    super.key,
    required this.reputation,
  });

  @override
  Widget build(BuildContext context) {
    final ratingValue = reputation.displayRating;
    final int starsToFill = ratingValue != null ? ratingValue.round() : 0;
    final label = reputation.statusLabel;

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                reputation.formattedRating,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              if (reputation.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified,
                  color: Color(0xFF2563EB), // Azul verificado
                  size: 24,
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          RatingStarsBar(
            rating: starsToFill,
            isInteractive: false,
            starSize: 22.0,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: reputation.isProvisional
                  ? const Color(0xFFB45309) // Ámbar oscuro
                  : const Color(0xFF6B7280), // Gris
            ),
          ),
          if (reputation.isProvisional) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Usuario verificado con nivel inicial de confianza',
                style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para exhibir el listado de reseñas u opiniones de un usuario
class UserReviewsListWidget extends StatelessWidget {
  final List<Review> reviews;

  const UserReviewsListWidget({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(Icons.rate_review_outlined, size: 36, color: Color(0xFF9CA3AF)),
            SizedBox(height: 8),
            Text(
              'Aún no se han recibido opiniones.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return ReviewListItem(review: reviews[index]);
      },
    );
  }
}
