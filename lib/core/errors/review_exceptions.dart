/// Excepción base para el módulo de calificaciones y reputación
abstract class ReviewException implements Exception {
  final String message;

  const ReviewException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Disparada cuando un usuario intenta calificarse a sí mismo
class SelfRatingNotAllowedException extends ReviewException {
  const SelfRatingNotAllowedException([
    super.message = 'No puedes calificarte a ti mismo.',
  ]);
}

/// Disparada cuando ya existe una calificación previa para la misma solicitud y emisor
class AlreadyRatedException extends ReviewException {
  const AlreadyRatedException([
    super.message = 'Ya has emitido una calificación para esta solicitud.',
  ]);
}

/// Disparada cuando se intenta calificar transcurrida la ventana límite (ej. 60 días)
class RatingWindowExpiredException extends ReviewException {
  const RatingWindowExpiredException([
    super.message = 'El plazo para calificar esta solicitud ha expirado.',
  ]);
}

/// Disparada cuando el usuario no es parte formal (arrendador ni arrendatario) de la postulación
class UnauthorizedRatingException extends ReviewException {
  const UnauthorizedRatingException([
    super.message = 'No tienes autorización para calificar esta solicitud.',
  ]);
}

/// Disparada cuando la contraparte fue eliminada o dada de baja
class TargetUserUnavailableException extends ReviewException {
  const TargetUserUnavailableException([
    super.message = 'El usuario a evaluar ya no se encuentra disponible en la plataforma.',
  ]);
}

/// Disparada cuando la sesión del usuario ha expirado durante el envío
class SessionExpiredRatingException extends ReviewException {
  const SessionExpiredRatingException([
    super.message = 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.',
  ]);
}

/// Disparada cuando los datos de la calificación no cumplen con las reglas del dominio
class ReviewValidationException extends ReviewException {
  const ReviewValidationException(super.message);
}
