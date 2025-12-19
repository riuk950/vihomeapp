import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';

class SolicitudesArrendadorPage extends StatefulWidget {
  const SolicitudesArrendadorPage({super.key});

  @override
  State<SolicitudesArrendadorPage> createState() =>
      _SolicitudesArrendadorPageState();
}

class _SolicitudesArrendadorPageState extends State<SolicitudesArrendadorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appProvider = Provider.of<ApplicationProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        appProvider.fetchLandlordApplications(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definición de colores del diseño
    const backgroundLight = Color(0xFFF6F7F8);
    // const backgroundDark = Color(0xFF101922); // Si implementamos dark mode

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Solicitudes de Arriendo',
          style: TextStyle(
            color: Color(0xFF111418),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111418)),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF111418)),
            onPressed: () {
              // TODO: Mostrar filtro avanzado si es necesario
            },
          ),
        ],
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          return Column(
            children: [
              // Filtros (Tabs)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      isSelected: provider.currentFilter == 'Todas',
                      onTap: () => provider.setFilter('Todas'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Pendientes',
                      isSelected: provider.currentFilter == 'Pendientes',
                      onTap: () => provider.setFilter('Pendientes'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Revisadas',
                      isSelected: provider.currentFilter == 'Revisadas',
                      onTap: () => provider.setFilter('Revisadas'),
                    ),
                  ],
                ),
              ),

              // Lista de solicitudes
              Expanded(
                child: provider.filteredApplications.isEmpty
                    ? const Center(child: Text('No hay solicitudes'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredApplications.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final app = provider.filteredApplications[index];
                          return _ApplicationCard(
                            application: app,
                            provider: provider,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF137FEC);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(999), // full rounded
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application application;
  final ApplicationProvider provider;

  const _ApplicationCard({required this.application, required this.provider});

  @override
  Widget build(BuildContext context) {
    final bool isPending = application.estado.toLowerCase() == 'pendiente';
    final statusColor = isPending
        ? Colors.amber[700]
        : (application.estado.toLowerCase() == 'aceptada'
              ? Colors.green
              : Colors.red);
    final statusBgColor = isPending
        ? Colors.amber[100]
        : (application.estado.toLowerCase() == 'aceptada'
              ? Colors.green[100]
              : Colors.red[100]);

    // Format date simple
    final date = application.createdAt;
    final dateStr =
        '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          // Header: User info y status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar placeholder
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.nombreArrendatario ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111418),
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  application.estado.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Property Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50], // Slate 50
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.apartment, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.tituloPropiedad ?? 'Propiedad',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Arriendo: \$${application.precioRenta?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          isPending
              ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Acción de revisar (podría ir a detalle o cambiar estado)
                          // Por ahora simular aceptar/rechazar en un dialogo o acción directa
                          _showReviewDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF137FEC),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Revisar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Placeholder responder
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Responder'),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Ver Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          backgroundColor: Colors.grey[100],
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gestionar Solicitud'),
        content: const Text('¿Qué deseas hacer con esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.updateStatus(application.id, 'rechazada');
            },
            child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.updateStatus(application.id, 'aceptada');
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
