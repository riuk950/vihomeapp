import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/core/utils/text_sanitizer.dart';

typedef LaunchUrlHandler = Future<bool> Function(Uri url, {LaunchMode? mode});
typedef ClipboardHandler = Future<void> Function(String text);

/// Servicio para lanzar llamadas telefónicas y conversaciones de WhatsApp de forma segura (RF-20.2, QA 1.1, QA 1.4, QA 1.13, QA 1.17).
class ExternalContactLauncher {
  /// Construye la URI para llamada telefónica nativa (`tel:<numero>`).
  static Uri buildPhoneUri(String phoneNumber) {
    final clean = TextSanitizer.sanitizePhone(phoneNumber);
    return Uri(scheme: 'tel', path: clean);
  }

  /// Construye la URI para WhatsApp (`https://wa.me/<numero>?text=<mensaje>`).
  /// Si el número tiene 10 dígitos (estándar nacional Colombia), antepone el prefijo internacional '57'.
  static Uri buildWhatsAppUri(String phoneNumber, {String? message}) {
    String clean = TextSanitizer.sanitizePhone(phoneNumber);
    if (clean.startsWith('+')) {
      clean = clean.substring(1);
    }
    if (clean.length == 10 && !clean.startsWith('57')) {
      clean = '57$clean';
    }

    return Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '/$clean',
      queryParameters: (message != null && message.trim().isNotEmpty)
          ? {'text': message}
          : null,
    );
  }

  /// Genera el mensaje plantilla estándar de contacto para WhatsApp (QA 1.17).
  static String buildWhatsAppDefaultMessage({
    required String recipientName,
    required String propertyTitle,
  }) {
    final cleanRecipient = TextSanitizer.cleanSingleLine(recipientName);
    final cleanTitle = TextSanitizer.cleanSingleLine(propertyTitle);
    return 'Hola $cleanRecipient, te contacto desde ViHome respecto a la postulación para el inmueble $cleanTitle';
  }

  /// Lanza el marcador telefónico del dispositivo.
  /// Retorna `true` si la llamada se ejecutó exitosamente, o `false` en caso de error o falta de app.
  static Future<bool> launchPhone(
    String phoneNumber, {
    LaunchUrlHandler? launcher,
  }) async {
    try {
      final uri = buildPhoneUri(phoneNumber);
      final execute = launcher ??
          ((u, {mode}) => launchUrl(u, mode: mode ?? LaunchMode.platformDefault));
      return await execute(uri);
    } catch (_) {
      return false;
    }
  }

  /// Lanza la aplicación de WhatsApp.
  /// Retorna `true` si se abrió la conversación exitosamente, o `false` si no está instalada o falla.
  static Future<bool> launchWhatsApp(
    String phoneNumber, {
    String? message,
    LaunchUrlHandler? launcher,
  }) async {
    try {
      final uri = buildWhatsAppUri(phoneNumber, message: message);
      final execute = launcher ??
          ((u, {mode}) => launchUrl(u, mode: mode ?? LaunchMode.externalApplication));
      return await execute(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Copia un texto al portapapeles del sistema de manera segura.
  static Future<void> copyToClipboard(
    String text, {
    ClipboardHandler? clipboardSetter,
  }) async {
    try {
      if (clipboardSetter != null) {
        await clipboardSetter(text);
      } else {
        await Clipboard.setData(ClipboardData(text: text));
      }
    } catch (_) {}
  }

  /// Muestra una retroalimentación accesible en pantalla mediante un [SnackBar]
  /// cuando falla el lanzamiento de una llamada o de WhatsApp, permitiendo copiar el número.
  static void showContactFailureFeedback(
    BuildContext context, {
    required String phoneNumber,
    required String contactType,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No se pudo abrir $contactType. Tel: $phoneNumber'),
        action: SnackBarAction(
          label: 'Copiar',
          onPressed: () => copyToClipboard(phoneNumber),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
