/// Resumen visual y numérico de reputación de un usuario
class ReputationSummary {
  final double? displayRating;
  final String statusLabel;
  final bool isProvisional;
  final bool hasRealRatings;

  const ReputationSummary({
    required this.displayRating,
    required this.statusLabel,
    required this.isProvisional,
    required this.hasRealRatings,
  });
}

/// Utilidad matemática pura para cálculos de promedio, redondeo y estados de confianza
class RatingCalculator {
  /// Redondea un valor numérico a un (1) dígito decimal utilizando la regla
  /// matemática simétrica round-half-up (4.85 -> 4.9, 4.84 -> 4.8).
  static double roundToOneDecimal(double value) {
    return (value * 10).round() / 10;
  }

  /// Calcula el promedio aritmético de una lista de calificaciones enteras (1 a 5).
  /// Retorna `null` si la lista está vacía, evitando indeterminaciones por división entre cero.
  static double? calculateAverage(List<int> ratings) {
    if (ratings.isEmpty) return null;
    final sum = ratings.fold<int>(0, (prev, element) => prev + element);
    final rawAverage = sum / ratings.length;
    return roundToOneDecimal(rawAverage);
  }

  /// Determina el resumen de reputación considerando si el usuario está verificado
  /// y cuántas calificaciones reales ha recibido.
  static ReputationSummary getReputationSummary({
    required int totalReviews,
    required double? averageRating,
    required bool isVerified,
  }) {
    if (totalReviews == 0) {
      if (isVerified) {
        return const ReputationSummary(
          displayRating: 3.0,
          statusLabel: 'Puntaje inicial de confianza',
          isProvisional: true,
          hasRealRatings: false,
        );
      }
      return const ReputationSummary(
        displayRating: null,
        statusLabel: 'Sin calificaciones aún',
        isProvisional: false,
        hasRealRatings: false,
      );
    }

    final double validRating = averageRating != null
        ? roundToOneDecimal(averageRating)
        : 0.0;

    final String label = totalReviews == 1
        ? 'Basado en 1 reseña'
        : 'Basado en $totalReviews reseñas';

    return ReputationSummary(
      displayRating: validRating,
      statusLabel: label,
      isProvisional: false,
      hasRealRatings: true,
    );
  }
}
