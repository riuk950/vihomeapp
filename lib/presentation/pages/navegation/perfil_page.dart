import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/presentation/widgets/msn_user_complete.dart';
import 'package:vihomeapp/presentation/widgets/msn_user_verificado.dart';
import 'package:vihomeapp/presentation/widgets/alert_dialog.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/application_provider.dart';
import '../../../env/env_def.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Cargar perfil del arrendatario si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user?.role == 'arrendatario') {
        final tenantProvider = Provider.of<TenantProvider>(
          context,
          listen: false,
        );
        if (tenantProvider.tenant == null && !tenantProvider.isLoading) {
          tenantProvider.loadTenantProfile(user!.id);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Cuando la app vuelve al primer plano (ej. tras regresar de Play Store),
      // recargar el estado del usuario por si canceló la suscripción.
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user?.isPremium == true) {
        authProvider.reloadUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8), // background-light
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFF0F172A), // slate-900
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            final isVerified = user?.role == 'arrendador'
                ? Provider.of<LandlordProvider>(context).isVerified
                : Provider.of<TenantProvider>(context).isVerified;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Color(0xFFF6F7F8),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido ${user?.role == 'arrendatario' ? 'Arrendatario' : 'Propietario'}',
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
                              const SizedBox(height: 8),
                              const Text(
                                'Gestiona tus propiedades y solicitudes',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF617589)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (user?.role == 'arrendatario') ...[
                          Consumer<TenantProvider>(
                            builder: (context, tenantProvider, child) {
                              if (tenantProvider.isLoading) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }

                              final isVerified = tenantProvider.isVerified;

                              if (isVerified) {
                                return MsnUserVerificado();
                              } else {}
                              return MsnUserComplete(
                                onPressed: () {
                                  context.push('/complete-profile');
                                },
                              );
                            },
                          ),
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Last Activity Card
                  /*  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
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
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuB-jdvGq_Vdp1WK46DPGItomwu8mHGyX5XmpFRvufKR8wUWzCSB-bgcn0eSM6n1MWl9buBhyDEKAgpwW_lB9D-JOIiX38s0r4kNZv-MvaloAeeJyoMq_BtfqdRPuwx_PXf4YSQDXm_yQOB9UZx4emjjAo7cUT-9udn2amhlIPo2MZ74sSzniyTdAZInAt5yvLLckyCWvu9DsYZy4-Nx6DqpcE91BaIor59AP0pbVLKxU1-aMvi-_xTUtmeWo2aVAwn1vEUBGl4o7CI',
                              cacheWidth: 720,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ÚLTIMA ACTIVIDAD',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Contrato Activo: Av. Principal 123',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Próximo pago: 01 de Julio, 2024',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 0,
                                        ),
                                        minimumSize: const Size(0, 32),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Ver Contrato'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), */

                  // Become Landlord Banner
                  if (user?.role == 'arrendatario')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: InkWell(
                        onTap: () => _showBecomeLandlordDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.real_estate_agent,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Conviértete en Arrendador',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Publica tus propiedades y gestiona tus arriendos.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Menu Options
                  _buildMenuOption(
                    context,
                    Icons.person_outline,
                    'Información Personal',
                    route: '/personal-info',
                    locked: !isVerified,
                  ),
                  _buildMenuOption(
                    context,
                    Icons.history,
                    'Historial de Solicitudes',
                    route: '/solicitudes-arrendatario',
                    locked: !isVerified,
                  ),
                  // _buildMenuOption(
                  //   context,
                  //   Icons.description_outlined,
                  //   'Mis Contratos',
                  // ),
                  _buildMenuOption(
                    context,
                    Icons.notifications_none,
                    'Notificaciones',
                    route: user?.role == 'arrendador'
                        ? '/notifications_landlord'
                        : '/notifications_tenant',
                    locked: !isVerified,
                  ),
                  _buildMenuOption(
                    context,
                    (user?.isPremium ?? false)
                        ? Icons.workspace_premium
                        : Icons.block,
                    (user?.isPremium ?? false)
                        ? 'Mi Suscripción Premium'
                        : 'Quitar anuncios',
                    // Si ya es premium → abre el gestor de suscripciones de Play Store
                    // Si no es premium → navega a la página de suscripción
                    onTap: (user?.isPremium ?? false)
                        ? () async {
                            final packageName = 'com.vihomeapp.vihomeapp';
                            final url = Uri.parse(
                              'https://play.google.com/store/account/subscriptions?package=$packageName',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          }
                        : null,
                    route: (user?.isPremium ?? false) ? null : '/subscription',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Divider(),
                  ),
                  _buildMenuOption(
                    context,
                    Icons.help_outline,
                    'Preguntas Frecuentes',
                    onTap: () async {
                      final url = Uri.parse('https://vihome.web.app/#/faq');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.inAppWebView);
                      }
                    },
                  ),
                  _buildMenuOption(
                    context,
                    Icons.description_outlined,
                    'Terminos y Condiciones',
                    onTap: () async {
                      final url = Uri.parse('https://vihome.web.app/#/terms');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.inAppWebView);
                      }
                    },
                  ),
                  _buildMenuOption(
                    context,
                    Icons.description_outlined,
                    'Politicas de tratamiento de datos',
                    onTap: () async {
                      final url = Uri.parse('https://vihome.web.app/#/privacy');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.inAppWebView);
                      }
                    },
                  ),
                  // Logout Option
                  InkWell(
                    onTap: () => _handleLogout(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.logout, color: Colors.red),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (EnvDef.flavor == 'dev')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Versión ${EnvDef.appVersion} (${EnvDef.flavor})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (EnvDef.flavor == 'prod')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Versión ${EnvDef.appVersion}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const AlertDialogWidget(
        icon: Icons.logout,
        title: 'Cerrar sesión',
        content: '¿Estás seguro de que quieres cerrar sesión?',
        cancelText: 'Cancelar',
        acceptText: 'Cerrar sesión',
      ),
    );

    if (confirm == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tenantProvider =
          Provider.of<TenantProvider>(context, listen: false);
      final landlordProvider =
          Provider.of<LandlordProvider>(context, listen: false);
      final appProvider =
          Provider.of<ApplicationProvider>(context, listen: false);

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

  Future<void> _showBecomeLandlordDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const AlertDialogWidget(
        icon: Icons.real_estate_agent,
        title: 'Conviértete en Arrendador',
        content:
            '¿Estás seguro de que quieres convertirte en Arrendador? Podrás publicar tus propiedades y gestionar tus arriendos.',
        cancelText: 'Cancelar',
        acceptText: 'Confirmar',
      ),
    );

    if (confirm == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final landlordProvider =
          Provider.of<LandlordProvider>(context, listen: false);

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await authProvider.becomeLandlord();

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading

        if (success) {
          // Cargar perfil de arrendador (puede que no exista aún)
          final userId = authProvider.user?.id;
          if (userId != null) {
            await landlordProvider.loadLandlordProfile(userId);
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Ahora eres Arrendador!'),
                backgroundColor: Colors.green,
              ),
            );
            // Redirigir a completar perfil de arrendador
            context.push('/complete-landlord-profile');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? 'Error al cambiar de rol',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildMenuOption(
    BuildContext context,
    IconData icon,
    String title, {
    String? route,
    VoidCallback? onTap,
    bool locked = false,
  }) {
    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: InkWell(
        onTap: onTap ??
            () {
              if (route != null && !locked) {
                context.push(route);
              }
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
