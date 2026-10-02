import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import 'rating_stars_bar.dart';

/// Modal interactivo deslizable inferior para emitir una calificación de 1 a 5 estrellas
class RatingBottomSheetModal extends StatefulWidget {
  final String solicitudId;
  final String reviewerId;
  final String? reviewerName;
  final String targetUserId;
  final String? targetUserName;
  final String? targetRoleTitle;

  const RatingBottomSheetModal({
    super.key,
    required this.solicitudId,
    required this.reviewerId,
    this.reviewerName,
    required this.targetUserId,
    this.targetUserName,
    this.targetRoleTitle,
  });

  /// Despliega el modal en la parte inferior de la pantalla
  static Future<bool?> show(
    BuildContext context, {
    required String solicitudId,
    required String reviewerId,
    String? reviewerName,
    required String targetUserId,
    String? targetUserName,
    String? targetRoleTitle,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => RatingBottomSheetModal(
        solicitudId: solicitudId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        targetRoleTitle: targetRoleTitle,
      ),
    );
  }

  @override
  State<RatingBottomSheetModal> createState() => _RatingBottomSheetModalState();
}

class _RatingBottomSheetModalState extends State<RatingBottomSheetModal> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(ReviewProvider provider) async {
    if (_selectedRating == 0) {
      setState(() {
        _localError = 'Debes seleccionar una puntuación obligatoria de 1 a 5 estrellas.';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    final success = await provider.submitReview(
      solicitudId: widget.solicitudId,
      reviewerId: widget.reviewerId,
      reviewerName: widget.reviewerName,
      targetUserId: widget.targetUserId,
      rating: _selectedRating,
      comment: _commentController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Calificación enviada exitosamente!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      } else {
        setState(() {
          _localError = provider.errorMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final targetName = widget.targetUserName ?? 'Usuario';
    final targetRole = widget.targetRoleTitle;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de arrastre superior
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Título
            Text(
              'Calificar a $targetName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            if (targetRole != null) ...[
              const SizedBox(height: 4),
              Text(
                targetRole,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            // Selector de estrellas
            Center(
              child: RatingStarsBar(
                rating: _selectedRating,
                isInteractive: !provider.isLoading,
                starSize: 38.0,
                onRatingChanged: (value) {
                  setState(() {
                    _selectedRating = value;
                    _localError = null;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // Campo de comentario opcional con contador de 500 caracteres
            TextField(
              controller: _commentController,
              enabled: !provider.isLoading,
              maxLines: 4,
              maxLength: 500,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                return Text(
                  '$currentLength/$maxLength',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                );
              },
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Escribe un comentario opcional sobre tu experiencia...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
            // Mensaje de error si aplica
            if (_localError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _localError!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 18),
            // Botón de acción principal
            ElevatedButton(
              onPressed: provider.isLoading ? null : () => _handleSubmit(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Enviar Calificación',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
