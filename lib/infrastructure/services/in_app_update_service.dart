import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Servicio que gestiona las actualizaciones en Play Store mediante la API
/// de Google Play In-App Updates.
///
/// Solo aplica para Android. En iOS no tiene efecto ya que App Store no
/// ofrece una API equivalente.
///
/// Modos de actualización:
/// - **Flexible**: el usuario puede seguir usando la app mientras descarga.
/// - **Inmediata (Immediate)**: la app se bloquea y obliga a actualizar.
class InAppUpdateService {
  InAppUpdateService._();

  /// Verifica si hay una actualización disponible en Play Store y la presenta
  /// al usuario de forma automática.
  ///
  /// [forceImmediate]: si es `true`, siempre usará el flujo de actualización
  /// inmediata (ideal para versiones críticas). De lo contrario, usa el modo
  /// flexible cuando hay actualizaciones disponibles.
  static Future<void> checkForUpdate({bool forceImmediate = false}) async {
    // Solo aplica en Android
    if (!Platform.isAndroid) return;

    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

      if (kDebugMode) {
        debugPrint(
          '[InAppUpdateService] Estado: ${info.updateAvailability}',
        );
        debugPrint(
          '[InAppUpdateService] Prioridad: ${info.updatePriority}',
        );
        debugPrint(
          '[InAppUpdateService] Días de espera: ${info.clientVersionStalenessDays}',
        );
      }

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Prioridad 4-5 en Play Console o forceImmediate → actualización obligatoria
        final bool isHighPriority =
            (info.updatePriority >= 4) || forceImmediate;

        if (isHighPriority && info.immediateUpdateAllowed) {
          await _startImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          await _startFlexibleUpdate();
        }
      }
    } catch (e) {
      // En dev o cuando la app no está publicada, la API no devuelve info real.
      if (kDebugMode) {
        debugPrint('[InAppUpdateService] No se pudo verificar actualización: $e');
      }
    }
  }

  /// Inicia el flujo de actualización INMEDIATA.
  /// La aplicación se congela hasta que el usuario actualiza.
  static Future<void> _startImmediateUpdate() async {
    if (kDebugMode) {
      debugPrint('[InAppUpdateService] Iniciando actualización inmediata...');
    }
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      if (kDebugMode) {
        debugPrint('[InAppUpdateService] Resultado inmediata: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InAppUpdateService] Error en actualización inmediata: $e');
      }
    }
  }

  /// Inicia el flujo de actualización FLEXIBLE.
  /// El usuario puede seguir usando la app mientras la actualización se descarga.
  static Future<void> _startFlexibleUpdate() async {
    if (kDebugMode) {
      debugPrint('[InAppUpdateService] Iniciando actualización flexible...');
    }
    try {
      final AppUpdateResult result = await InAppUpdate.startFlexibleUpdate();
      if (kDebugMode) {
        debugPrint('[InAppUpdateService] Resultado flexible: $result');
      }
      if (result == AppUpdateResult.success) {
        // Una vez descargada, aplica la actualización y reinicia la app.
        await InAppUpdate.completeFlexibleUpdate();
        if (kDebugMode) {
          debugPrint('[InAppUpdateService] Actualización flexible completada.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InAppUpdateService] Error en actualización flexible: $e');
      }
    }
  }
}
