import 'package:flutter/foundation.dart';
import '../../core/errors/review_exceptions.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/user_reputation.dart';
import '../../domain/repositories/review_repository.dart';

/// Gestor de estado (Provider) para el Sistema de Calificación y Reputación
class ReviewProvider extends ChangeNotifier {
  final ReviewRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  int? _draftRating;
  String? _draftComment;

  // Cachés en memoria por ID de usuario / solicitud
  final Map<String, UserReputation> _reputations = {};
  final Map<String, List<Review>> _userReviews = {};
  final Map<String, bool> _canRateStatus = {};

  ReviewProvider(this.repository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get draftRating => _draftRating;
  String? get draftComment => _draftComment;

  /// Obtiene la reputación almacenada en caché para un usuario (o null si no se ha consultado)
  UserReputation? getReputationFor(String userId) => _reputations[userId];

  /// Obtiene la lista de opiniones almacenadas en caché para un usuario
  List<Review>? getReviewsFor(String userId) => _userReviews[userId];

  /// Indica si el usuario actual puede calificar la solicitud indicada
  bool? canRate(String solicitudId, String userId) =>
      _canRateStatus['${solicitudId}_$userId'];

  /// Limpia los borradores y mensajes de error
  void clearDraft() {
    _draftRating = null;
    _draftComment = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Actualiza los valores de borrador mientras el usuario interactúa con el modal
  void updateDraft({int? rating, String? comment}) {
    if (rating != null) _draftRating = rating;
    if (comment != null) _draftComment = comment;
  }

  /// Envía una calificación para una solicitud completada
  Future<bool> submitReview({
    required String solicitudId,
    required String reviewerId,
    required String targetUserId,
    required int rating,
    String? comment,
    String? reviewerName,
  }) async {
    // 1. Bloqueo de concurrencia: evitar doble clic durante petición activa (RF-28.2, CL-20)
    if (_isLoading) return false;

    // 2. Validación de estrellas obligatorias (RF-24.1, RF-24.4)
    if (rating < 1 || rating > 5) {
      _errorMessage = 'Debes seleccionar una puntuación obligatoria de 1 a 5 estrellas.';
      _draftRating = rating;
      _draftComment = comment;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _draftRating = rating;
    _draftComment = comment;
    notifyListeners();

    try {
      final review = await repository.createReview(
        solicitudId: solicitudId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        targetUserId: targetUserId,
        rating: rating,
        comment: comment,
      );

      // Invalida/actualiza el estado de elegibilidad para calificar
      _canRateStatus['${solicitudId}_$reviewerId'] = false;

      // Actualiza la lista en memoria si ya estaba cargada
      final existing = _userReviews[targetUserId] ?? [];
      _userReviews[targetUserId] = [review, ...existing];

      // Re-consulta reactiva de reputación para actualizar el promedio de inmediato (RF-25.2)
      await fetchUserReputation(targetUserId);

      // Éxito: limpiar borrador
      _draftRating = null;
      _draftComment = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ReviewException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error al enviar tu calificación. Inténtalo nuevamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Consulta y almacena en caché la reputación de un usuario
  Future<UserReputation> fetchUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async {
    try {
      final reputation = await repository.getUserReputation(
        userId,
        isVerified: isVerified,
        userName: userName,
      );
      _reputations[userId] = reputation;
      notifyListeners();
      return reputation;
    } catch (e) {
      final fallback = UserReputation(
        userId: userId,
        userName: userName,
        isVerified: isVerified,
      );
      _reputations[userId] = fallback;
      notifyListeners();
      return fallback;
    }
  }

  /// Consulta y almacena en caché la lista de opiniones recibidas por un usuario
  Future<List<Review>> fetchUserReviews(String userId) async {
    try {
      final reviews = await repository.getUserReviews(userId);
      _userReviews[userId] = reviews;
      notifyListeners();
      return reviews;
    } catch (e) {
      return _userReviews[userId] ?? [];
    }
  }

  /// Verifica si el usuario actual puede calificar la solicitud
  Future<bool> checkCanRate({
    required String solicitudId,
    required String userId,
  }) async {
    final cacheKey = '${solicitudId}_$userId';
    try {
      final can = await repository.canUserRateApplication(
        solicitudId: solicitudId,
        userId: userId,
      );
      _canRateStatus[cacheKey] = can;
      notifyListeners();
      return can;
    } catch (e) {
      return false;
    }
  }
}
