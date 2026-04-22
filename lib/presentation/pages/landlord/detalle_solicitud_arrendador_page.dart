import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

class DetalleSolicitudArrendadorPage extends StatefulWidget {
  final Application application;

  const DetalleSolicitudArrendadorPage({super.key, required this.application});

  @override
  State<DetalleSolicitudArrendadorPage> createState() =>
      _DetalleSolicitudArrendadorPageState();
}

class _DetalleSolicitudArrendadorPageState
    extends State<DetalleSolicitudArrendadorPage> {
  bool _isProcessing = false;
  Tenant? _tenant;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTenant();
    });
  }

  Future<void> _loadTenant() async {
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
    final tenant = await tenantProvider.getTenantById(
      widget.application.arrendatarioId,
    );
    if (mounted && tenant != null) {
      setState(() {
        _tenant = tenant;
      });
    }
  }

  void _updateStatus(String newStatus) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = Provider.of<ApplicationProvider>(context, listen: false);
      final success = await provider.updateStatus(
        widget.application.id,
        newStatus,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Solicitud ${newStatus.toLowerCase()} exitosamente',
              ),
              backgroundColor:
                  newStatus == 'aceptada' ? Colors.green : Colors.red,
            ),
          );
          Navigator.pop(context); // Go back to list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al actualizar: ${provider.errorMessage}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colors & Styles
    const primaryColor = Color(0xFF137FEC);
    final isPending = widget.application.estado.toLowerCase() == 'pendiente';
    final priceFormat = NumberFormat.currency(locale: 'es_CL', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detalle de Postulación',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Applicant Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: primaryColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tenant?.primerNombre ?? 'Postulante',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (_tenant != null) ...[
                              Text(
                                '${_tenant!.primerApellido} ${_tenant!.segundoApellido ?? ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                _tenant!.telefonoContacto,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              'Solicitado el ${DateFormat('dd MMM yyyy').format(widget.application.createdAt)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(widget.application.estado),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Income & Employment Info
                const Text(
                  'Información Laboral y Financiera',
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
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Empresa',
                        widget.application.empresa ?? 'N/A',
                        Icons.business,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Cargo',
                        widget.application.cargo ?? 'N/A',
                        Icons.badge,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Tiempo Empleo',
                        '${widget.application.tiempoEmpleo ?? 0} meses',
                        Icons.timer,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Ingresos Mensuales',
                        widget.application.ingresosMensuales != null
                            ? priceFormat.format(
                                double.tryParse(
                                      widget.application.ingresosMensuales!,
                                    ) ??
                                    0,
                              )
                            : 'N/A',
                        Icons.attach_money,
                      ),
                      if (widget.application.otrosIngresos != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Otros Ingresos',
                          widget.application.otrosIngresos!,
                          Icons.add_circle_outline,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // References
                const Text(
                  'Referencias Personales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.application.refPersonales == null ||
                    widget.application.refPersonales!.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No hay referencias personales',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...widget.application.refPersonales!.map(
                    (ref) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ref.telefono,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.people,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ref.relacion,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Documents
                const Text(
                  'Documentos Adjuntos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.application.documentoUrl == null ||
                    widget.application.documentoUrl!.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No hay documentos adjuntos',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...widget.application.documentoUrl!.split(',').map((url) {
                    final uri = Uri.parse(url);
                    String filename = uri.pathSegments.isNotEmpty
                        ? uri.pathSegments.last
                        : 'Documento';

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
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Colors.red,
                        ),
                        title: Text(
                          filename,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.open_in_new, size: 20),
                        onTap: () => launchUrl(Uri.parse(url)),
                      ),
                    );
                  }),
              ],
            ),
          ),

          // Bottom Actions
          if (isPending)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateStatus('rechazada'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateStatus('aceptada'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Aceptar Solicitud'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[600], size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'aceptada':
        color = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case 'rechazada':
        color = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
        break;
      default:
        color = Colors.amber[800]!;
        bgColor = Colors.amber.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
