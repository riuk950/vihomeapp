import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import '../../../domain/entities/project.dart';

class DetallesProyectoPage extends StatelessWidget {
  final Project project;
  const DetallesProyectoPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Contenido scrolleable
          CustomScrollView(
            slivers: [
              // Hero Image + AppBar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                leading: IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                ],
                title: const Text(
                  'Proyecto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen placeholder
                      Container(
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: Icon(
                            Icons.apartment,
                            size: 80,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      // Badge de estado
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(project.estado),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            project.estado,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de información principal
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                      child: Transform.translate(
                        offset: const Offset(0, -24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tipo y precio
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.tipoPropiedad,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Estrato ${project.estrato}',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Desde',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(project.precioDesde),
                                        style: const TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Chips de características
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildChip(
                                    Icons.bed_outlined,
                                    '${project.habitaciones} hab',
                                    isPrimary: true,
                                  ),
                                  _buildChip(
                                    Icons.straighten,
                                    '${project.area.toStringAsFixed(0)} m²',
                                    isPrimary: true,
                                  ),
                                  _buildChip(
                                    Icons.location_on_outlined,
                                    project.ubicacionPrincipal,
                                    isPrimary: false,
                                  ),
                                  if (project.parqueaderos > 0)
                                    _buildChip(
                                      Icons.directions_car_outlined,
                                      '${project.parqueaderos} parq.',
                                      isPrimary: false,
                                    ),
                                  if (project.financiacion)
                                    _buildChip(
                                      Icons.payments_outlined,
                                      'Financiación',
                                      isPrimary: true,
                                    ),
                                  if (project.aplicaSubsidio)
                                    _buildChip(
                                      Icons.volunteer_activism_outlined,
                                      'Aplica Subsidio',
                                      isPrimary: true,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Descripción
                    _buildSection(
                      context,
                      title: 'Descripción del Proyecto',
                      child: Text(
                        project.descripcion.isNotEmpty
                            ? project.descripcion
                            : 'Sin descripción disponible.',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Detalles adicionales
                    _buildSection(
                      context,
                      title: 'Información del Proyecto',
                      child: _buildInfoGrid(project),
                    ),

                    // Amenidades (derivadas de características si existen)
                    _buildSection(
                      context,
                      title: 'Amenidades',
                      headerAction: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _buildAmenities(project),
                        ),
                      ),
                    ),

                    // Sección de mapa / ubicación
                    _buildSection(
                      context,
                      title: 'Ubicación',
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 40,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project.ubicacionPrincipal,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Lat: ${project.lat.toStringAsFixed(4)}, Lng: ${project.lng.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Fecha de entrega (si aplica)
                    if (project.fechaFinalizacion != null)
                      _buildSection(
                        context,
                        title: 'Fecha de Entrega',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(project.fechaFinalizacion!),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Espacio para el bottom bar
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),

          // Botones sticky en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.97),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      label: const Text(
                        'Contactar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withValues(alpha: 0.4),
                      ),
                      child: const Text(
                        'Solicitar Información',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
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

  // ── Helpers de UI ─────────────────────────────────────────────────────────

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? headerAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (headerAction != null) headerAction,
            ],
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? primaryColor.withValues(alpha: 0.1)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isPrimary ? primaryColor : const Color(0xFF64748B),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPrimary ? primaryColor : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(Project project) {
    final items = [
      (Icons.layers_outlined, 'Pisos', '${project.cantidadPisos}'),
      (Icons.bathtub_outlined, 'Baños', '${project.banos}'),
      (
        Icons.attach_money,
        'Cuota Inicial',
        _formatCurrency(project.coutaInicial)
      ),
      (
        Icons.price_change_outlined,
        'Precio Hasta',
        _formatCurrency(project.precioHasta)
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.0,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(item.$1, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildAmenities(Project project) {
    // Amenidades estándar de proyectos inmobiliarios
    final amenities = [
      (Icons.pool_outlined, 'Piscina'),
      (Icons.fitness_center, 'Gimnasio'),
      (Icons.security_outlined, 'Seguridad 24/7'),
      (Icons.park_outlined, 'Zonas Verdes'),
      (Icons.local_parking_outlined, 'Parqueadero'),
      (Icons.elevator_outlined, 'Ascensor'),
    ];

    return amenities.map((item) {
      return Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.$1, color: primaryColor, size: 28),
            const SizedBox(height: 6),
            Text(
              item.$2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'en construcción':
      case 'en construccion':
        return primaryColor;
      case 'entrega inmediata':
        return const Color(0xFF10B981);
      case 'sobre planos':
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy', 'es');
    return formatter.format(date);
  }
}
