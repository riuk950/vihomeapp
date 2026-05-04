import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';

class NotificationsTenantPage extends StatefulWidget {
  const NotificationsTenantPage({super.key});

  @override
  State<NotificationsTenantPage> createState() =>
      _NotificationsTenantPageState();
}

class _NotificationsTenantPageState extends State<NotificationsTenantPage> {
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
        appProvider.fetchTenantApplications(authProvider.user!.id);
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
          'Mis Notificaciones',
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
          notifications.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

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
    // Formatear fecha
    final date = application.updatedAt;
    final dateStr =
        '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () {
        context.push('/detalle-solicitud', extra: application);
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
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Lato',
                      ),
                      children: [
                        const TextSpan(text: 'Tu solicitud para '),
                        TextSpan(
                          text: application.tituloPropiedad ?? 'la propiedad',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' ha sido '),
                        TextSpan(
                          text: _getEstadoTexto(application.estado),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(application.estado),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEstadoTexto(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'enviada y está pendiente de revisión';
      case 'aceptada':
        return 'ACEPTADA';
      case 'rechazada':
        return 'RECHAZADA';
      default:
        return estado;
    }
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFF137FEC);
      case 'aceptada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusIcon(String estado) {
    Color color = _getStatusColor(estado);
    IconData icon;

    switch (estado.toLowerCase()) {
      case 'pendiente':
        icon = Icons.send_outlined;
        break;
      case 'aceptada':
        icon = Icons.check_circle_outline;
        break;
      case 'rechazada':
        icon = Icons.cancel_outlined;
        break;
      default:
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
