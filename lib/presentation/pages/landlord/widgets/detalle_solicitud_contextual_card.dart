import 'package:flutter/material.dart';
import 'package:vihomeapp/domain/entities/application_context_data.dart';

/// Tarjeta de visualización contextual para el arrendador [RF-17.1, RF-17.2]
class DetalleSolicitudContextualCard extends StatelessWidget {
  final ApplicationContextData? contextData;

  const DetalleSolicitudContextualCard({super.key, required this.contextData});

  @override
  Widget build(BuildContext context) {
    if (contextData == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Solicitud estándar previa (sin datos contextuales adicionales)',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return switch (contextData!) {
      ResidentialContextData res => _buildResidentialCard(res),
      IndividualContextData ind => _buildIndividualCard(ind),
      CommercialContextData com => _buildCommercialCard(com),
    };
  }

  Widget _buildResidentialCard(ResidentialContextData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Composición Familiar y Convivencia',
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
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildRow('Ocupantes previstos', '${data.numeroOcupantes} personas', Icons.people_outline),
              const Divider(height: 20),
              _buildRow('Núcleo familiar', data.descripcionFamiliar, Icons.family_restroom),
              const Divider(height: 20),
              _buildRow(
                'Mascotas',
                data.tieneMascotas
                    ? 'Sí - ${data.detalleMascotas ?? "Sin detalle"}'
                    : 'No',
                Icons.pets_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualCard(IndividualContextData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ocupación y Solicitante',
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
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildRow('Ocupación principal', data.ocupacion, Icons.work_outline),
              const Divider(height: 20),
              _buildRow('Institución o empresa', data.entidadLaboralEducativa, Icons.school_outlined),
              const Divider(height: 20),
              _buildRow('¿Es menor de edad?', data.esMenorDeEdad ? 'Sí' : 'No', Icons.child_care),
              if (data.esMenorDeEdad && data.acudiente != null) ...[
                const Divider(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Datos del Acudiente Responsable:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRow('Nombre del acudiente', data.acudiente!.nombreCompleto, Icons.person_outline),
                      const SizedBox(height: 8),
                      _buildRow('Teléfono del acudiente', data.acudiente!.telefono, Icons.phone_outlined),
                      const SizedBox(height: 8),
                      _buildRow('Parentesco', data.acudiente!.parentesco, Icons.supervised_user_circle_outlined),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommercialCard(CommercialContextData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Comercial',
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
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildRow('Razón social', data.razonSocial, Icons.storefront_outlined),
              const Divider(height: 20),
              _buildRow('NIT / Doc. Tributario', data.nit, Icons.receipt_long_outlined),
              const Divider(height: 20),
              _buildRow('Actividad económica', data.actividadEconomica, Icons.business_center_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
