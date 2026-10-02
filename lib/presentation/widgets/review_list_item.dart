import 'package:flutter/material.dart';
import '../../core/utils/application_date_formatter.dart';
import '../../domain/entities/review.dart';
import 'rating_stars_bar.dart';

/// Elemento visual de lista para representar una opinión o reseña individual
class ReviewListItem extends StatefulWidget {
  final Review review;

  const ReviewListItem({
    super.key,
    required this.review,
  });

  @override
  State<ReviewListItem> createState() => _ReviewListItemState();
}

class _ReviewListItemState extends State<ReviewListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final authorName = (review.reviewerName != null && review.reviewerName!.trim().isNotEmpty)
        ? review.reviewerName!.trim()
        : 'Usuario';
    final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U';
    final formattedDate = ApplicationDateFormatter.format(review.createdAt);
    final comment = review.comment?.trim() ?? '';
    final isLongComment = comment.length > 100;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE0E7FF), // Azul pastel
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3730A3),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              RatingStarsBar(
                rating: review.rating,
                isInteractive: false,
                starSize: 14.0,
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.35,
              ),
            ),
            if (isLongComment) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'Ver menos' : 'Ver más',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
