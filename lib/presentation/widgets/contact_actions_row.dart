import 'package:flutter/material.dart';
import 'package:vihomeapp/core/utils/external_contact_launcher.dart';
import 'package:vihomeapp/core/utils/text_sanitizer.dart';

/// Fila compacta de acciones directas de contacto (Llamada telefónica y WhatsApp).
///
/// Cumple con las reglas de negocio y validaciones de visibilidad:
/// - Oculta los botones si el número de teléfono es nulo, vacío o inválido (RF-20.3, CL-16).
/// - Oculta los botones para ambas partes si la solicitud está en estado 'rechazada' (RF-19.3, QA 1.7).
/// - En la vista de arrendatario (`isTenantView = true`), solo habilita contacto si la solicitud está 'aceptada' (RF-19.1, RF-19.2).
/// - En la vista de arrendador (`isTenantView = false`), permite contactar en solicitudes 'pendiente' o 'aceptada'.
class ContactActionsRow extends StatelessWidget {
  /// Número telefónico de la contraparte.
  final String? phoneNumber;

  /// Nombre del destinatario para la plantilla de mensaje de WhatsApp.
  final String? recipientName;

  /// Título de la propiedad para la plantilla de mensaje de WhatsApp.
  final String? propertyTitle;

  /// Estado de la postulación ('pendiente', 'aceptada', 'rechazada', etc.).
  final String status;

  /// Indica si la fila se renderiza en la vista del inquilino (true) o arrendador (false).
  final bool isTenantView;

  /// Callback opcional para interceptar la acción de llamada en pruebas o flujos personalizados.
  final VoidCallback? onCall;

  /// Callback opcional para interceptar la acción de WhatsApp en pruebas o flujos personalizados.
  final VoidCallback? onWhatsApp;

  /// Inyección opcional del despachador de URLs para pruebas automatizadas.
  final LaunchUrlHandler? launcher;

  const ContactActionsRow({
    super.key,
    required this.phoneNumber,
    this.recipientName,
    this.propertyTitle,
    required this.status,
    this.isTenantView = false,
    this.onCall,
    this.onWhatsApp,
    this.launcher,
  });

  bool get _isValidPhoneNumber {
    if (phoneNumber == null || phoneNumber!.trim().isEmpty) return false;
    final sanitized = TextSanitizer.sanitizePhone(phoneNumber).replaceAll('+', '');
    return sanitized.length >= 7;
  }

  bool get _shouldShowButtons {
    if (!_isValidPhoneNumber) return false;

    final normStatus = status.trim().toLowerCase();

    // Regla simétrica: solicitudes rechazadas no tienen contacto directo para ninguna parte
    if (normStatus == 'rechazada') return false;

    if (isTenantView) {
      // El arrendatario solo contacta cuando fue aceptado
      return normStatus == 'aceptada' || normStatus == 'aprobada';
    } else {
      // El arrendador puede contactar solicitudes pendientes o aceptadas
      return normStatus == 'pendiente' ||
          normStatus == 'aceptada' ||
          normStatus == 'aprobada';
    }
  }

  Future<void> _handleCall(BuildContext context) async {
    if (onCall != null) {
      onCall!();
      return;
    }

    final success = await ExternalContactLauncher.launchPhone(
      phoneNumber!,
      launcher: launcher,
    );

    if (!success && context.mounted) {
      ExternalContactLauncher.showContactFailureFeedback(
        context,
        phoneNumber: phoneNumber!,
        contactType: 'llamada',
      );
    }
  }

  Future<void> _handleWhatsApp(BuildContext context) async {
    if (onWhatsApp != null) {
      onWhatsApp!();
      return;
    }

    final message = ExternalContactLauncher.buildWhatsAppDefaultMessage(
      recipientName: recipientName ?? 'Usuario',
      propertyTitle: propertyTitle ?? 'Inmueble',
    );

    final success = await ExternalContactLauncher.launchWhatsApp(
      phoneNumber!,
      message: message,
      launcher: launcher,
    );

    if (!success && context.mounted) {
      ExternalContactLauncher.showContactFailureFeedback(
        context,
        phoneNumber: phoneNumber!,
        contactType: 'WhatsApp',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowButtons) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón compacto de llamada directa (Verde esmeralda - Decisión 1)
        IconButton(
          key: const Key('contact_call_button'),
          tooltip: 'Llamar',
          icon: const Icon(Icons.phone, size: 18),
          onPressed: () => _handleCall(context),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        // Botón compacto de WhatsApp (Verde WhatsApp - Decisión 1)
        IconButton(
          key: const Key('contact_whatsapp_button'),
          tooltip: 'WhatsApp',
          icon: const Icon(Icons.chat_bubble, size: 18),
          onPressed: () => _handleWhatsApp(context),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
