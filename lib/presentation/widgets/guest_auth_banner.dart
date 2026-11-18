import 'package:flutter/material.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';

/// Banner informativo contextual mostrado en la pantalla de inicio de sesión
/// cuando un usuario invitado intenta acceder a una sección o acción restringida.
class GuestAuthBanner extends StatelessWidget {
  final String message;

  const GuestAuthBanner({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Aviso informativo: $message',
      child: Container(
        key: const Key('guest_auth_banner'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF4FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.info_outline_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF002A4A),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
