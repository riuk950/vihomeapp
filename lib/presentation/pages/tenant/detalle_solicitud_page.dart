import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/domain/entities/application.dart';

class DetalleSolicitudPage extends StatelessWidget {
  final Application application;

  const DetalleSolicitudPage({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    // Determine status color and icon
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    String statusTitle;
    String statusDesc;

    switch (application.estado.toLowerCase()) {
      case 'aprobada':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withValues(alpha: 0.1);
        statusIcon = Icons.check_circle;
        statusTitle = 'Solicitud Aprobada';
        statusDesc =
            '¡Felicidades! Tu solicitud ha sido aprobada. El arrendador se pondrá en contacto pronto.';
        break;
      case 'rechazada':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withValues(alpha: 0.1);
        statusIcon = Icons.cancel;
        statusTitle = 'Solicitud Rechazada';
        statusDesc =
            'Lo sentimos, tu solicitud no ha sido aceptada en esta ocasión.';
        break;
      default:
        statusColor = const Color(0xFFB45309); // Dark yellow/orange
        statusBgColor = const Color(0xFFFFFBEB); // Light yellow
        statusIcon = Icons.hourglass_empty;
        statusTitle = 'Solicitud Pendiente';
        statusDesc =
            'Tu solicitud está siendo revisada por el arrendador. Te notificaremos cuando haya una actualización sobre tu postulación.';
    }

    final priceFormat = NumberFormat.currency(locale: 'es_CL', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detalle de Solicitud',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Menu options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Placeholder image or real image if available
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.tituloPropiedad ??
                                    'Propiedad sin título',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                application.direccionPropiedad ??
                                    'Dirección no disponible',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${priceFormat.format(application.precioRenta ?? 0)} / mes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF137FEC),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ID Propiedad: #${application.propiedadId.substring(0, 8)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Navigate to property details
                                    },
                                    child: const Text(
                                      'Ver ficha completa',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Status Section
                  const Text(
                    'Estado actual',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                statusDesc,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: statusColor.withValues(alpha: 0.8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Application Info
                  const Text(
                    'Información de la postulación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Fecha solicitud',
                          DateFormat(
                            'dd MMM, yyyy',
                          ).format(application.createdAt),
                        ),
                        const Divider(height: 24),
                        // Mock/Static data as requested fields are not in DB yet, or map to what we have
                        _buildInfoRow('Empresa', application.empresa ?? 'N/A'),
                        const Divider(height: 24),
                        _buildInfoRow('Cargo', application.cargo ?? 'N/A'),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Ingresos',
                          application.ingresosMensuales != null
                              ? priceFormat.format(
                                  double.tryParse(
                                        application.ingresosMensuales!,
                                      ) ??
                                      0,
                                )
                              : 'N/A',
                        ),
                        // _buildInfoRow('Fecha de ingreso', '01 Nov, 2023'),
                        // const Divider(height: 24),
                        // _buildInfoRow('Duración contrato', '12 Meses'),
                        // const Divider(height: 24),
                        // _buildInfoRow('Ocupantes', '2 Adultos'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Documents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Documentos adjuntos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Edit documents
                        },
                        child: const Text('Editar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (application.documentoUrl == null ||
                      application.documentoUrl!.isEmpty)
                    const Text('No hay documentos adjuntos.')
                  else
                    ...application.documentoUrl!.split(',').map((url) {
                      final uri = Uri.parse(url);
                      // Try to get filename from path segment, decode it carefully
                      String filename = uri.pathSegments.isNotEmpty
                          ? uri.pathSegments.last
                          : 'Documento';

                      // Remove timestamp prefix if present (format: timestamp_name)
                      if (filename.contains('_')) {
                        final parts = filename.split('_');
                        if (parts.length > 1 &&
                            double.tryParse(parts[0]) != null) {
                          filename = parts.sublist(1).join('_');
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.description,
                              color: Color(0xFFEF4444), // PDF red color
                            ),
                          ),
                          title: Text(
                            filename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: const Text('Documento Adjunto'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_red_eye_outlined),
                            onPressed: () {
                              launchUrl(Uri.parse(url));
                            },
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
