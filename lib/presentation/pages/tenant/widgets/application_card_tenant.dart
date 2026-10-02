import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/core/utils/application_date_formatter.dart';
import 'package:vihomeapp/core/utils/external_contact_launcher.dart';
import 'package:vihomeapp/core/utils/text_sanitizer.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/presentation/widgets/contact_actions_row.dart';
import 'package:vihomeapp/presentation/widgets/rating_bottom_sheet_modal.dart';

/// Tarjeta estructurada de alta densidad para postulaciones enviadas por el Arrendatario.
/// Incluye bloque visual distintivo de "Paso siguiente" (RF-18.1, RF-18.3, RF-19, RF-20.1, RF-20.2, CL-15, CL-16, QA 1.6).
class ApplicationCardTenant extends StatelessWidget {
  /// Entidad de la postulación a representar.
  final Application application;

  /// Callback de navegación personalizado (útil en pruebas de widget).
  final VoidCallback? onTap;

  /// Inyección del despachador de URLs para pruebas automatizadas.
  final LaunchUrlHandler? launcher;

  const ApplicationCardTenant({
    super.key,
    required this.application,
    this.onTap,
    this.launcher,
  });

  @override
  Widget build(BuildContext context) {
    final propertyTitle = TextSanitizer.cleanSingleLine(
      application.tituloPropiedad ?? 'Inmueble no disponible',
    );
    final landlordName = TextSanitizer.cleanSingleLine(
      application.nombreArrendador ?? 'Arrendador no disponible',
    );
    final formattedDate =
        ApplicationDateFormatter.format(application.createdAt);

    final statusLower = application.estado.toLowerCase();

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    String statusLabel;

    switch (statusLower) {
      case 'pendiente':
        statusColor = Colors.amber.shade800;
        statusBgColor = Colors.amber.shade50;
        statusIcon = Icons.hourglass_top_rounded;
        statusLabel = 'PENDIENTE';
        break;
      case 'aceptada':
      case 'aprobada':
        statusColor = Colors.green.shade700;
        statusBgColor = Colors.green.shade50;
        statusIcon = Icons.check_circle_outline;
        statusLabel = 'ACEPTADA';
        break;
      case 'rechazada':
        statusColor = Colors.red.shade700;
        statusBgColor = Colors.red.shade50;
        statusIcon = Icons.cancel_outlined;
        statusLabel = 'RECHAZADA';
        break;
      default:
        statusColor = Colors.grey.shade700;
        statusBgColor = Colors.grey.shade100;
        statusIcon = Icons.help_outline;
        statusLabel = application.estado.toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2.0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: onTap ??
              () {
                context.push(
                  '/detalle-solicitud',
                  extra: application,
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila Superior: Ícono Inmueble, Título, Propietario e Insignia
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Título de propiedad, arrendador y fecha
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            propertyTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Propietario: $landlordName',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Insignia de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bloque visual de "Paso siguiente" (RF-19.1, RF-19.2, RF-19.3)
                _buildNextStepBlock(context, statusLower),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Fila inferior: Acción contextual 'Ver detalles' y 'Calificar Propietario' si está aceptada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (statusLower == 'aceptada' || statusLower == 'aprobada')
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          foregroundColor: const Color(0xFFD97706),
                        ),
                        icon: const Icon(Icons.star, size: 14),
                        label: const Text(
                          'Calificar Propietario',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          RatingBottomSheetModal.show(
                            context,
                            solicitudId: application.id,
                            reviewerId: application.arrendatarioId,
                            reviewerName: application.nombreArrendatario,
                            targetUserId: application.arrendadorId,
                            targetUserName: application.nombreArrendador,
                            targetRoleTitle: 'Propietario',
                          );
                        },
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver detalle',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepBlock(BuildContext context, String statusLower) {
    if (statusLower == 'pendiente') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: Colors.amber.shade800,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Esperando respuesta del propietario',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else if (statusLower == 'aceptada' || statusLower == 'aprobada') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: Colors.green.shade800,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Contacto habilitado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Botones de llamada y WhatsApp hacia el propietario (RF-19.2)
            ContactActionsRow(
              phoneNumber: application.telefonoArrendador,
              recipientName: application.nombreArrendador,
              propertyTitle: application.tituloPropiedad,
              status: application.estado,
              isTenantView: true,
              launcher: launcher,
            ),
          ],
        ),
      );
    } else {
      // Rechazada u otro
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 16,
              color: Colors.red.shade800,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Solicitud no aprobada',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }
}
