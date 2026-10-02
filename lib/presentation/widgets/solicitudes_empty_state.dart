import 'package:flutter/material.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';

/// Componente visual ilustrado para representar estados vacíos en listas de solicitudes.
///
/// Soporta estados vacíos globales (sin solicitudes) y estados vacíos por filtrado sin coincidencias.
/// (RF-22.1, RF-22.2, RNF-12).
class SolicitudesEmptyState extends StatelessWidget {
  /// Ícono representativo del estado vacío.
  final IconData icon;

  /// Título principal en español claro.
  final String title;

  /// Mensaje explicativo o guía de acción.
  final String message;

  /// Texto del botón de acción contextual (opcional).
  final String? actionLabel;

  /// Callback invocado al presionar el botón de acción principal.
  final VoidCallback? onAction;

  /// Color personalizado para el ícono y su halo circular.
  final Color? iconColor;

  const SolicitudesEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  /// Estado vacío para el Arrendatario que no cuenta con postulaciones registradas (RF-22.1).
  factory SolicitudesEmptyState.tenant({
    Key? key,
    required VoidCallback onExplore,
  }) {
    return SolicitudesEmptyState(
      key: key,
      icon: Icons.search_outlined,
      title: 'No tienes postulaciones',
      message:
          'Aún no te has postulado a ningún inmueble. Explora las propiedades disponibles y envía tu solicitud.',
      actionLabel: 'Explorar inmuebles',
      onAction: onExplore,
    );
  }

  /// Estado vacío para el Arrendador que no cuenta con solicitudes recibidas (RF-22.1).
  factory SolicitudesEmptyState.landlord({
    Key? key,
    required VoidCallback onManageProperties,
  }) {
    return SolicitudesEmptyState(
      key: key,
      icon: Icons.real_estate_agent_outlined,
      title: 'No tienes solicitudes recibidas',
      message:
          'Aquí aparecerán las solicitudes de las personas interesadas en alquilar tus propiedades.',
      actionLabel: 'Ver mis propiedades',
      onAction: onManageProperties,
    );
  }

  /// Estado vacío cuando un filtro activo no contiene registros coincidentes (RF-22.2).
  factory SolicitudesEmptyState.filtered({
    Key? key,
    required String filterName,
    VoidCallback? onClearFilter,
  }) {
    return SolicitudesEmptyState(
      key: key,
      icon: Icons.filter_alt_off_outlined,
      title: 'Sin solicitudes en "$filterName"',
      message:
          'No hay solicitudes bajo este estado actualmente. Consulta las demás pestañas para ver tus postulaciones.',
      actionLabel: onClearFilter != null ? 'Ver todas' : null,
      onAction: onClearFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? primaryColor;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Halo circular con ícono alegórico
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(height: 20),
            // Título conciso
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            // Mensaje explicativo
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            // Botón de acción principal contextual (RF-22.1)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const Key('empty_state_action_button'),
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
