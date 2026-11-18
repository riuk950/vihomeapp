import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/guest_redirect_context.dart';
import '../../presentation/providers/auth_provider.dart';

/// Guarda centralizada de acceso para acciones restringidas al rol invitado.
///
/// Verifica si el usuario actual está autenticado. En caso contrario,
/// intercepta la acción y navega a `/login` pasando un [GuestRedirectContext]
/// con protección contra pulsaciones rápidas consecutivas (doble toque).
class GuestAccessGuard {
  GuestAccessGuard._();

  static const Duration _debounceWindow = Duration(milliseconds: 350);
  static DateTime? _lastRedirectAt;
  static DateTime Function() _clock = DateTime.now;

  /// Verifica si existe una sesión autenticada.
  ///
  /// - Retorna `true` si el usuario está autenticado y puede continuar la acción.
  /// - Retorna `false` si es invitado, redirigiendo una única vez a `/login`
  ///   mediante `context.push` para preservar la vista pública subyacente.
  static bool requireAuth(
    BuildContext context, {
    required GuestRedirectReason reason,
    required String sourcePath,
    String? customMessage,
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      return true;
    }

    // Evitar apilar múltiples pantallas de login si ya estamos en /login
    try {
      final currentLocation = GoRouterState.of(context).matchedLocation;
      if (currentLocation == '/login') {
        return false;
      }
    } catch (_) {
      // GoRouterState puede no estar presente en contextos de prueba aislados
    }

    final now = _clock();
    if (_lastRedirectAt != null &&
        now.difference(_lastRedirectAt!) < _debounceWindow) {
      return false;
    }
    _lastRedirectAt = now;

    final redirectContext = GuestRedirectContext.fromReason(
      reason,
      sourcePath: sourcePath,
      canReturnToPreviousView: true,
      customMessage: customMessage,
    );

    context.push('/login', extra: redirectContext);
    return false;
  }

  /// Libera la ventana de bloqueo (por ejemplo al cerrar `/login` o en tests).
  static void resetDebounce() {
    _lastRedirectAt = null;
  }

  /// Permite inyectar un reloj determinista en pruebas unitarias.
  @visibleForTesting
  static void configureClockForTesting(DateTime Function() clock) {
    _clock = clock;
  }

  /// Restaura el estado interno del guard para pruebas.
  @visibleForTesting
  static void resetForTesting() {
    _lastRedirectAt = null;
    _clock = DateTime.now;
  }
}
