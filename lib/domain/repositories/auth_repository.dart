import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../entities/user.dart';

/// Interfaz del repositorio de autenticación
abstract class AuthRepository {
  /// Obtiene el usuario actual autenticado
  Future<Either<Failure, User?>> getCurrentUser();
  
  /// Inicia sesión con email y contraseña
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });
  
  /// Registra un nuevo usuario
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  });
  
  /// Cierra sesión
  Future<Either<Failure, void>> signOut();
  
  /// Solicita restablecimiento de contraseña
  Future<Either<Failure, void>> resetPassword(String email);
  
  /// Actualiza la contraseña
  Future<Either<Failure, void>> updatePassword(String newPassword);
  
  /// Stream de cambios en el estado de autenticación
  Stream<Either<Failure, User?>> authStateChanges();
}

