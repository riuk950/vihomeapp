/// Clase base para errores de la aplicación
abstract class Failure {
  final String message;
  const Failure(this.message);
  
  @override
  String toString() => message;
}

/// Error de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Error de red
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error de caché
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

