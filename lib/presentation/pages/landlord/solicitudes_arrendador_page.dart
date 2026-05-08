import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

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
    return Scaffold(
      backgroundColor: backgroundColor,
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
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                        label: 'Aceptadas',
                        isSelected: provider.currentFilter == 'Aceptadas',
                        onTap: () => provider.setFilter('Aceptadas'),
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
                            tenantProvider: Provider.of<TenantProvider>(
                              context,
                              listen: false,
                            ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : backgroundColor,
          borderRadius: BorderRadius.circular(999), // full rounded
          border: Border.all(
            color: isSelected ? primaryColor : disabledColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? backgroundColor : disabledColor,
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
  final TenantProvider tenantProvider;

  const _ApplicationCard({
    required this.application,
    required this.provider,
    required this.tenantProvider,
  });

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
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: textColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: disabledColor),
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
                  color: disabledColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: backgroundColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Tenant?>(
                      future: tenantProvider.getTenantById(
                        application.arrendatarioId,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox.shrink();
                        }
                        final tenant = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${tenant.primerNombre} ${tenant.primerApellido}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (application.ingresosMensuales != null)
                      Text(
                        'Ingresos: \$${application.ingresosMensuales}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                        ),
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
              color: disabledColor, // Slate 50
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
          Row(
            children: [
              Expanded(
                child: isPending
                    ? ElevatedButton(
                        onPressed: () {
                          context.push(
                            '/detalle-solicitud-arrendador',
                            extra: application,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: backgroundColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Revisar'),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          context.push(
                            '/detalle-solicitud-arrendador',
                            extra: application,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Ver Detalles'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
