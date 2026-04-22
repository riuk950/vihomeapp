import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

class NotificationsLandlordPage extends StatefulWidget {
  const NotificationsLandlordPage({super.key});

  @override
  State<NotificationsLandlordPage> createState() =>
      _NotificationsLandlordPageState();
}

class _NotificationsLandlordPageState extends State<NotificationsLandlordPage> {
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
    const backgroundLight = Color(0xFFF6F7F8);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
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
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          final notifications = List<Application>.from(provider.applications);
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes notificaciones aún',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final app = notifications[index];
              return _NotificationItem(application: app);
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Application application;

  const _NotificationItem({required this.application});

  @override
  Widget build(BuildContext context) {
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);

    // Formatear fecha
    final date = application.createdAt;
    final dateStr =
        '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () {
        context.push('/detalle-solicitud-arrendador', extra: application);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono según el estado
            _buildStatusIcon(application.estado),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<Tenant?>(
                    future: tenantProvider.getTenantById(application.arrendatarioId),
                    builder: (context, snapshot) {
                      final tenantName = snapshot.hasData
                          ? '${snapshot.data!.primerNombre} ${snapshot.data!.primerApellido}'
                          : 'Un arrendatario';
                      
                      return RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Lato', // Usar fuente del proyecto si está disponible
                          ),
                          children: [
                            TextSpan(
                              text: tenantName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ' ha enviado una solicitud para '),
                            TextSpan(
                              text: application.tituloPropiedad ?? 'tu propiedad',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            // Indicador de "Nueva" si es pendiente
            if (application.estado.toLowerCase() == 'pendiente')
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF137FEC),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String estado) {
    Color color;
    IconData icon;

    switch (estado.toLowerCase()) {
      case 'pendiente':
        color = const Color(0xFF137FEC);
        icon = Icons.assignment_late_outlined;
        break;
      case 'aceptada':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'rechazada':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
