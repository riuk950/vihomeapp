import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'arriendos_page.dart';
import 'ventas_page.dart';
import '../proyectos/proyectos_page.dart';
import '../user/perfil_page.dart';
import 'panel_page.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../../infrastructure/services/push_notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null) {
        if (user.role == 'arrendador') {
          appProvider.fetchLandlordApplications(user.id);
        } else {
          appProvider.fetchTenantApplications(user.id);
        }
      }

      // Procesar notificación inicial si la app se abrió desde una
      PushNotificationService.handleInitialMessage();
    });
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
