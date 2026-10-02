import '../../core/utils/rating_calculator.dart';

/// Entidad de Reputación agregada para un usuario del sistema
class UserReputation {
  final String userId;
  final String? userName;
  final bool isVerified;
  final double? averageRating;
  final int totalReviews;

  const UserReputation({
    required this.userId,
    this.userName,
    this.isVerified = false,
    this.averageRating,
    this.totalReviews = 0,
  });

  /// Puntuación a desplegar visualmente (3.0 para verificados nuevos, o el promedio real redondeado)
  double? get displayRating {
    return RatingCalculator.getReputationSummary(
      totalReviews: totalReviews,
      averageRating: averageRating,
      isVerified: isVerified,
    ).displayRating;
  }

  /// Etiqueta descriptiva del estado de confianza
  String get statusLabel {
    return RatingCalculator.getReputationSummary(
      totalReviews: totalReviews,
      averageRating: averageRating,
      isVerified: isVerified,
    ).statusLabel;
  }

  /// Indica si el puntaje exhibido es provisional (3.0 base para verificados)
  bool get isProvisional {
    return RatingCalculator.getReputationSummary(
      totalReviews: totalReviews,
      averageRating: averageRating,
      isVerified: isVerified,
    ).isProvisional;
  }

  /// Indica si el usuario cuenta con calificaciones reales de transacciones
  bool get hasRealRatings {
    return totalReviews > 0;
  }

  /// Formato corto legible del puntaje (ej. '4.8', '3.0' o '—')
  String get formattedRating {
    final rating = displayRating;
    if (rating == null) return '—';
    return rating.toStringAsFixed(1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserReputation &&
        other.userId == userId &&
        other.userName == userName &&
        other.isVerified == isVerified &&
        other.averageRating == averageRating &&
        other.totalReviews == totalReviews;
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      (userName?.hashCode ?? 0) ^
      isVerified.hashCode ^
      (averageRating?.hashCode ?? 0) ^
      totalReviews.hashCode;
}
