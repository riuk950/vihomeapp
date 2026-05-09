import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/presentation/pages/pages.dart';
import 'package:vihomeapp/presentation/providers/providers.dart';
import 'package:vihomeapp/infrastructure/services/push_notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _lastRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      _lastRole = user?.role;
      _loadApplicationsForRole(user?.role, user?.id);

      // Procesar notificación inicial si la app se abrió desde una
      PushNotificationService.handleInitialMessage();

      // Escuchar cambios futuros de rol
      authProvider.addListener(_onAuthChanged);
    });
  }

  @override
  void dispose() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final newRole = user?.role;

    // Solo recargar si el rol cambió efectivamente
    if (newRole != _lastRole) {
      _lastRole = newRole;
      _loadApplicationsForRole(newRole, user?.id);
    }
  }

  void _loadApplicationsForRole(String? role, String? userId) {
    if (userId == null) return;
    final appProvider =
        Provider.of<ApplicationProvider>(context, listen: false);
    if (role == 'arrendador') {
      appProvider.fetchLandlordApplications(userId);
    } else {
      appProvider.fetchTenantApplications(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isLandlord = user?.role == 'arrendador';

    final List<Widget> pages = [
      const ArriendosPage(),
      const VentasPage(),
      const ProyectosPage(),
      isLandlord ? const PanelPage() : const PerfilPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: backgroundColor,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: primaryColor,
            selectedIconTheme: const IconThemeData(size: 24),
            unselectedItemColor: disabledColor,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              const BottomNavigationBarItem(
                backgroundColor: primaryColor,
                icon: Icon(
                  Icons.home,
                ),
                label: 'Arriendos',
              ),
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.sell,
                ),
                label: 'Ventas',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_work),
                label: 'Proyectos',
              ),
              BottomNavigationBarItem(
                icon: Icon(isLandlord ? Icons.dashboard : Icons.person),
                label: isLandlord ? 'Panel' : 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
