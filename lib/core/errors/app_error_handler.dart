import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'failures.dart';

/// Manejador centralizado y unificado para transformar errores técnicos
/// de Supabase, Firebase, Google Sign-In y de Red en [Failure] con
/// mensajes amigables y en español para el usuario final.
class AppErrorHandler {
  AppErrorHandler._();

  /// Convierte cualquier tipo de excepción en un [Failure] adecuado con mensaje en español
  static Failure handle(dynamic error, [StackTrace? stackTrace]) {
    final Failure failure;

    // 1. Prioridad: Verificar primero si es un error de conectividad/red
    if (_isNetworkError(error)) {
      failure = const NetworkFailure(
        'No se pudo conectar con el servidor. Revisa tu conexión a internet e inténtalo nuevamente.',
      );
    } else if (error is AuthException) {
      failure = _handleSupabaseAuthException(error);
    } else if (error is PostgrestException) {
      failure = _handlePostgrestException(error);
    } else if (error is StorageException) {
      failure = _handleStorageException(error);
    } else if (error is FirebaseException) {
      failure = _handleFirebaseException(error);
    } else if (error is PlatformException) {
      failure = _handlePlatformException(error);
    } else if (error is Failure) {
      failure = error;
    } else {
      failure = _handleGenericError(error);
    }

    // Registro detallado en consola para depuración técnica
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('❌ [AppErrorHandler] Error Original: $error');
      if (error is AuthException) {
        debugPrint('   • Tipo: Supabase AuthException (${error.runtimeType})');
        debugPrint('   • StatusCode: ${error.statusCode}');
        debugPrint('   • Mensaje Técnico: ${error.message}');
      } else if (error is PostgrestException) {
        debugPrint('   • Tipo: Supabase PostgrestException');
        debugPrint('   • Código Postgres: ${error.code}');
        debugPrint('   • Mensaje Técnico: ${error.message}');
        if (error.details != null) debugPrint('   • Detalles: ${error.details}');
        if (error.hint != null) debugPrint('   • Hint: ${error.hint}');
      } else if (error is PlatformException) {
        debugPrint('   • Tipo: PlatformException (Google / Nativo)');
        debugPrint('   • Código: ${error.code}');
        debugPrint('   • Mensaje Técnico: ${error.message}');
        if (error.details != null) debugPrint('   • Detalles: ${error.details}');
      } else if (error is FirebaseException) {
        debugPrint('   • Tipo: FirebaseException');
        debugPrint('   • Código: ${error.code}');
        debugPrint('   • Mensaje Técnico: ${error.message}');
      }
      debugPrint('💬 [AppErrorHandler] Mensaje para Usuario: "${failure.message}"');
      if (stackTrace != null) {
        debugPrint('📜 [AppErrorHandler] StackTrace:\n$stackTrace');
      }
      debugPrint('═══════════════════════════════════════════════════════');
    }

    return failure;
  }

  /// Detecta si el error es debido a fallos de red, DNS, offline o timeouts
  static bool _isNetworkError(dynamic error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return true;
    }

    final raw = error.toString().toLowerCase();
    final message = (error is AuthException ? error.message : '').toLowerCase();

    return raw.contains('socketexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('no address associated with hostname') ||
        raw.contains('clientexception') ||
        raw.contains('authretryablefetchexception') ||
        raw.contains('network_error') ||
        raw.contains('network-request-failed') ||
        raw.contains('connection refused') ||
        raw.contains('connection timed out') ||
        raw.contains('connection closed') ||
        raw.contains('connection reset') ||
        raw.contains('handshakeexception') ||
        raw.contains('network is unreachable') ||
        raw.contains('errno = 7') ||
        raw.contains('errno = 8') ||
        raw.contains('errno = 61') ||
        raw.contains('xmlhttprequest error') ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('clientexception') ||
        message.contains('network');
  }

  /// Errores de Google Sign-In y Platform Channels nativos (Android / iOS)
  static Failure _handlePlatformException(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();

    // Casos comunes de Google Sign-In en Android / iOS
    if (code.contains('sign_in_canceled') ||
        code == '12501' ||
        message.contains('12501') ||
        message.contains('canceled') ||
        message.contains('cancelado')) {
      return const AuthFailure('Inicio de sesión con Google cancelado por el usuario.');
    }

    if (code.contains('network_error') ||
        code == '7' ||
        message.contains('network_error') ||
        message.contains('7:')) {
      return const NetworkFailure(
        'Error de conexión al conectar con Google. Revisa tu internet e inténtalo de nuevo.',
      );
    }

    if (code.contains('sign_in_failed') ||
        code == '10' ||
        code == '12500' ||
        message.contains('10:') ||
        message.contains('12500') ||
        message.contains('developer_error')) {
      return const AuthFailure(
        'Error de configuración con Google Sign-In (SHA-1 o Client ID no configurado).',
      );
    }

    if (code.contains('sign_in_required') || code == '4') {
      return const AuthFailure(
        'Debes iniciar sesión con tu cuenta de Google en el dispositivo.',
      );
    }

    if (code.contains('sign_in_in_progress') || code == '12502') {
      return const AuthFailure(
        'Ya hay un inicio de sesión de Google en proceso.',
      );
    }

    return AuthFailure(
      _cleanMessage(error.message, 'Ocurrió un error al autenticar con el dispositivo.'),
    );
  }

  /// Errores de Firebase (Cloud Messaging, Core, Analytics, Storage, etc.)
  static Failure _handleFirebaseException(FirebaseException error) {
    switch (error.code.toLowerCase()) {
      case 'permission-denied':
        return const ServerFailure('No tienes permisos suficientes para realizar esta acción.');
      case 'unavailable':
      case 'network-request-failed':
        return const NetworkFailure('El servicio no está disponible temporalmente. Revisa tu conexión.');
      case 'not-found':
        return const ServerFailure('El recurso solicitado no fue encontrado.');
      case 'already-exists':
        return const ServerFailure('El registro ya existe en el sistema.');
      case 'cancelled':
        return const ServerFailure('La operación fue cancelada.');
      case 'deadline-exceeded':
        return const NetworkFailure('Tiempo de espera agotado al procesar la solicitud.');
      case 'unauthenticated':
        return const AuthFailure('Tu sesión ha expirado o no estás autenticado.');
      case 'resource-exhausted':
      case 'quota-exceeded':
        return const ServerFailure('Se ha superado el límite de uso del servicio. Intenta más tarde.');
      case 'invalid-argument':
        return const ValidationFailure('Los parámetros enviados son inválidos.');
      case 'too-many-requests':
        return const AuthFailure('Demasiadas solicitudes. Por favor espera unos minutos antes de intentar de nuevo.');
      default:
        return ServerFailure(
          _cleanMessage(error.message, 'Ocurrió un error en el servidor.'),
        );
    }
  }

  /// Errores del módulo de Autenticación de Supabase (GoTrue)
  static AuthFailure _handleSupabaseAuthException(AuthException error) {
    final code = error.statusCode;
    final msg = error.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('invalid grant')) {
      return const AuthFailure('Correo electrónico o contraseña incorrectos.');
    }

    if (msg.contains('user already registered') ||
        msg.contains('user already exists') ||
        code == '422') {
      return const AuthFailure('Ya existe una cuenta registrada con este correo electrónico.');
    }

    if (msg.contains('email not confirmed')) {
      return const AuthFailure('Por favor, confirma tu correo electrónico antes de iniciar sesión.');
    }

    if (msg.contains('over_email_send_rate_limit') ||
        msg.contains('rate limit') ||
        code == '429') {
      return const AuthFailure(
        'Has realizado demasiados intentos. Por favor espera unos minutos antes de intentar de nuevo.',
      );
    }

    if (msg.contains('password should be at least') ||
        msg.contains('weak password')) {
      return const AuthFailure('La contraseña debe tener al menos 6 caracteres.');
    }

    if (msg.contains('user not found')) {
      return const AuthFailure('No se encontró ninguna cuenta asociada a este correo.');
    }

    if (msg.contains('token has expired') ||
        msg.contains('otp expired') ||
        msg.contains('invalid token')) {
      return const AuthFailure('El enlace o código de seguridad ha expirado o es inválido.');
    }

    if (msg.contains('signup disabled')) {
      return const AuthFailure('El registro de nuevos usuarios está deshabilitado temporalmente.');
    }

    // Si el mensaje técnico contiene URLs o datos crudos, sanitizarlo para el usuario
    return AuthFailure(
      _cleanMessage(error.message, 'No se pudo iniciar sesión. Verifica tus datos o intenta más tarde.'),
    );
  }

  /// Errores de Base de Datos (PostgREST / PostgreSQL)
  static ServerFailure _handlePostgrestException(PostgrestException error) {
    switch (error.code) {
      case '23505': // Unique violation
        return const ServerFailure('Ya existe un registro con estos datos en el sistema.');
      case '23503': // Foreign key violation
        return const ServerFailure(
          'No se puede completar la acción porque este registro está relacionado con otra información.',
        );
      case '42501': // Insufficient privilege / RLS policy violation
        return const ServerFailure('No tienes permisos suficientes para realizar esta operación.');
      case '23502': // Not null violation
        return const ServerFailure('Hay campos obligatorios que no han sido completados.');
      case 'PGRST116': // Single row expected but 0 or multiple returned
        return const ServerFailure('No se encontró la información solicitada.');
      default:
        return ServerFailure(
          _cleanMessage(error.message, 'Ocurrió un error en el servidor de base de datos.'),
        );
    }
  }

  /// Errores de Almacenamiento (Supabase Storage: fotos, documentos, etc.)
  static ServerFailure _handleStorageException(StorageException error) {
    final msg = error.message.toLowerCase();

    if (msg.contains('payload too large') || error.statusCode == '413') {
      return const ServerFailure('El archivo seleccionado es demasiado pesado. Por favor elige uno más pequeño.');
    }

    if (msg.contains('object not found') || error.statusCode == '404') {
      return const ServerFailure('El archivo solicitado no existe o fue eliminado.');
    }

    if (msg.contains('bucket not found')) {
      return const ServerFailure('El contenedor de archivos no está disponible.');
    }

    if (error.statusCode == '403' || msg.contains('unauthorized')) {
      return const ServerFailure('No tienes autorización para subir o modificar este archivo.');
    }

    return ServerFailure(
      _cleanMessage(error.message, 'Error al procesar el archivo en el servidor.'),
    );
  }

  static Failure _handleGenericError(dynamic error) {
    final rawError = error.toString();
    final lower = rawError.toLowerCase();

    if (lower.contains('google') && lower.contains('cancel')) {
      return const AuthFailure('Inicio de sesión con Google cancelado.');
    }

    return ServerFailure(
      _cleanMessage(rawError, 'Ocurrió un error inesperado. Por favor intenta más tarde.'),
    );
  }

  /// Sanitiza mensajes técnicos para no exponer URLs, tokens ni stacktraces al usuario final
  static String _cleanMessage(String? raw, String fallback) {
    if (raw == null || raw.trim().isEmpty) return fallback;

    final lower = raw.toLowerCase();
    // Si contiene URLs, llamadas HTTP, errores de socket o JSON crudo, devolver el fallback
    if (lower.contains('http://') ||
        lower.contains('https://') ||
        lower.contains('clientexception') ||
        lower.contains('socketexception') ||
        lower.contains('uri=') ||
        lower.contains('grant_type') ||
        lower.contains('exception:') ||
        lower.contains('{') ||
        lower.contains('stacktrace')) {
      return fallback;
    }

    return raw.startsWith('Exception: ') ? raw.substring(11) : raw;
  }
}
