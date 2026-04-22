import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/presentation/widgets/msn_user_complete.dart';
import 'package:vihomeapp/presentation/widgets/msn_user_verificado.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/application_provider.dart';

class PanelPage extends StatelessWidget {
  const PanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Load landlord profile if needed
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final landlordProvider = Provider.of<LandlordProvider>(
          context,
          listen: false,
        );
        if (landlordProvider.landlord == null && !landlordProvider.isLoading) {
          landlordProvider.loadLandlordProfile(user.id);
        }

        final appProvider = Provider.of<ApplicationProvider>(
          context,
          listen: false,
        );
        if (appProvider.applications.isEmpty && !appProvider.isLoading) {
          if (user.role == 'arrendador') {
            appProvider.fetchLandlordApplications(user.id);
          } else {
            appProvider.fetchTenantApplications(user.id);
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Panel de Control',
          style: TextStyle(
            color: Color(0xFF111418),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              color: backgroundColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido ${user?.role == 'arrendador' ? 'Arrendador' : 'Arrendatario'}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const Text(
                    'Gestiona tus propiedades y solicitudes',
                    style: TextStyle(fontSize: 16, color: Color(0xFF617589)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Verification Status Banner
            Consumer<LandlordProvider>(
              builder: (context, landlordProvider, child) {
                if (landlordProvider.isLoading) {
                  return const SizedBox.shrink();
                }

                final isVerified = landlordProvider.isVerified;

                if (isVerified) {
                  return MsnUserVerificado();
                } else {
                  return MsnUserComplete(
                    onPressed: () {
                      context.push('/complete-landlord-profile');
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111418),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.description_outlined,
                          title: 'Mis Documentos',
                          subtitle: 'Accede a tus documentos',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.person_outline,
                          title: 'Información Personal',
                          subtitle: 'Actualiza tus datos',
                          onTap: () {
                            context.push('/personal-info-landlord');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.home_outlined,
                          title: 'Mis Propiedades',
                          subtitle: 'Accede a tus propiedades',
                          onTap: () {
                            context.push('/mis-propiedades');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.list_alt_outlined,
                          title: 'Solicitudes',
                          subtitle: 'Revisa tus solicitudes',
                          onTap: () {
                            // Check role to navigate
                            final role = user?.role;
                            if (role == 'arrendador') {
                              context.push('/solicitudes-arrendador');
                            } else {
                              context.push('/solicitudes-arrendatario');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Application Status Card
            _buildApplicationStatusCard(context),
            const SizedBox(height: 16),

            // Contracts Card
            //_buildContractsCard(context),
            //const SizedBox(height: 16),

            _buildMenuConfig(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDBE0E6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: disabledColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationStatusCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Consumer<ApplicationProvider>(
      builder: (context, appProvider, child) {
        final apps = appProvider.applications;
        final pendientes = apps.where((a) => a.estado.toLowerCase() == 'pendiente').length;
        final aprobadas = apps.where((a) => a.estado.toLowerCase() == 'aceptada' || a.estado.toLowerCase() == 'aprobada').length;
        final rechazadas = apps.where((a) => a.estado.toLowerCase() == 'rechazada').length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para Arrendatarios y Arrendadores',
                style: TextStyle(fontSize: 12, color: disabledColor),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estado de Solicitudes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Revisa las últimas actualizaciones de tus postulaciones.',
                style: TextStyle(fontSize: 14, color: disabledColor),
              ),
              const SizedBox(height: 16),
              if (appProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              pendientes.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Pendientes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              aprobadas.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Aprobada',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              rechazadas.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Rechazadas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final role = user?.role;
                if (role == 'arrendador') {
                  context.push('/solicitudes-arrendador');
                } else {
                  context.push('/solicitudes-arrendatario');
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ver solicitudes',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  },
);
}

  Widget _buildMenuConfig(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('Administrar notificaciones'),
            leading: Icon(Icons.notifications),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push('/notifications_landlord');
            },
          ),
          Divider(),
          ListTile(
            title: Text('Terminos y condiciones'),
            leading: Icon(Icons.description),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            title: Text('Politicas de tratamiento de datos'),
            leading: Icon(Icons.description),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            title: Text('Preguntas frecuentes'),
            leading: Icon(Icons.question_mark),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            title: Text('Cerrar Sesión'),
            leading: Icon(Icons.logout),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }

  /* Widget _buildContractsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Documentos importantes',
                  style: TextStyle(fontSize: 12, color: Color(0xFF617589)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mis Contratos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111418),
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, color: Color(0xFF617589)),
                    children: [
                      TextSpan(text: 'Tienes '),
                      TextSpan(
                        text: '1 contrato activo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' y 2 finalizados. Accede a tus documentos de forma segura.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.priority_high,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const Text(
                          'El contrato del "Apartamento Central" requiere tu firma.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ver todos los contratos',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } */

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
      final landlordProvider = Provider.of<LandlordProvider>(context, listen: false);
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      
      try {
        // Aseguramos que la sesión se cierre a nivel de Supabase
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('Error al cerrar sesión en Supabase: $e');
      }
      
      // Limpiar el estado local de los demás Providers para la próxima sesión
      tenantProvider.clear();
      landlordProvider.clear();
      appProvider.clear();
      
      // Cerramos sesión a nivel de aplicación (Provider)
      await authProvider.signOut();
      
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}
