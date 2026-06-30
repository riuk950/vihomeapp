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
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: disabledColor),
                  const SizedBox(height: 12),
                  Text(
                    'Ocurrió un error',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: disabledColor, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filtros
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay solicitudes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: disabledColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Las solicitudes recibidas aparecerán aquí',
                              style: TextStyle(
                                fontSize: 13,
                                color: disabledColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredApplications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
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

// ---------------------------------------------------------------------------
// Filter Chip
// ---------------------------------------------------------------------------
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Application Card
// ---------------------------------------------------------------------------
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
    final statusLower = application.estado.toLowerCase();
    final bool isPending = statusLower == 'pendiente';

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (statusLower) {
      case 'pendiente':
        statusColor = Colors.amber[700]!;
        statusBgColor = Colors.amber[50]!;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'aceptada':
        statusColor = Colors.green[700]!;
        statusBgColor = Colors.green[50]!;
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.red[700]!;
        statusBgColor = Colors.red[50]!;
        statusIcon = Icons.cancel_outlined;
    }

    final date = application.createdAt;
    final dateStr =
        '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
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
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: primaryColor, size: 26),
                ),
                const SizedBox(width: 12),

                // Name + date + income
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
                            return const SizedBox(
                              height: 20,
                              width: 120,
                              child: LinearProgressIndicator(
                                backgroundColor: backgroundColor,
                                color: primaryColor,
                              ),
                            );
                          }
                          final tenant = snapshot.data!;
                          return Text(
                            '${tenant.primerNombre} ${tenant.primerApellido}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      if (application.ingresosMensuales != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Ingresos: \$${application.ingresosMensuales}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        application.estado.toUpperCase(),
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
          ),

          // ── Property info ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.apartment_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.tituloPropiedad ?? 'Propiedad',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Arriendo: \$${application.precioRenta?.toStringAsFixed(0) ?? '0'} / mes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider + action ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: isPending
                  ? ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '/detalle-solicitud-arrendador',
                          extra: application,
                        );
                      },
                      icon: const Icon(Icons.rate_review_outlined, size: 18),
                      label: const Text('Revisar solicitud'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: () {
                        context.push(
                          '/detalle-solicitud-arrendador',
                          extra: application,
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Ver detalles'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
