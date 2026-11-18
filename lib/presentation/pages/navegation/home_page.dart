import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/router/app_router.dart';
import 'package:vihomeapp/core/router/guest_access_guard.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/infrastructure/services/push_notification_service.dart';
import 'package:vihomeapp/presentation/pages/pages.dart';
import 'package:vihomeapp/presentation/providers/providers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  int _currentIndex = 0;
  String? _lastRole;
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _authProvider = authProvider;
      final user = authProvider.user;
      _lastRole = user?.role;
      _loadApplicationsForRole(user?.role, user?.id);

      if (_currentIndex == 3 && user != null) {
        _syncReputationForCurrentUser();
      }

      // Procesar notificación inicial solo para usuarios autenticados (RF-1.4)
      if (user != null) {
        PushNotificationService.handleInitialMessage();
      }

      // Escuchar cambios futuros de rol o cierre de sesión
      authProvider.addListener(_onAuthChanged);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _authProvider?.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Al regresar a HomePage desde otra pantalla, sincronizar si estamos en la pestaña 3
    if (_currentIndex == 3) {
      _syncReputationForCurrentUser();
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final newRole = user?.role;

    // Transición a modo invitado: regresar a Arriendos y limpiar datos privados (RF-7.3, RF-7.4, RNF-2)
    if (user == null) {
      if (_lastRole != null) {
        _lastRole = null;
        _clearPrivateProviders();
      }
      if (_currentIndex == 3) {
        setState(() {
          _currentIndex = 0;
        });
      }
      return;
    }

    // Solo recargar si el rol cambió efectivamente
    if (newRole != _lastRole) {
      _lastRole = newRole;
      _loadApplicationsForRole(newRole, user.id);
    }
  }

  void _clearPrivateProviders() {
    try {
      Provider.of<ApplicationProvider>(context, listen: false).clear();
    } catch (_) {}
    try {
      Provider.of<TenantProvider>(context, listen: false).clear();
    } catch (_) {}
    try {
      Provider.of<LandlordProvider>(context, listen: false).clear();
    } catch (_) {}
    try {
      Provider.of<SubscriptionProvider>(context, listen: false).clear();
    } catch (_) {}
  }

  void _syncReputationForCurrentUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    try {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      bool isVerified = false;
      if (user.role == 'arrendador') {
        try {
          isVerified =
              Provider.of<LandlordProvider>(context, listen: false).isVerified;
        } catch (_) {}
      } else {
        try {
          isVerified =
              Provider.of<TenantProvider>(context, listen: false).isVerified;
        } catch (_) {}
      }
      reviewProvider.fetchUserReputation(
        user.id,
        isVerified: isVerified,
        userName: user.email,
      );
      reviewProvider.fetchUserReviews(user.id);
    } catch (_) {}
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
    final isAuthenticated = user != null;
    final isLandlord = user?.role == 'arrendador';

    final List<Widget> pages = [
      const ArriendosPage(),
      const VentasPage(),
      const ProyectosPage(),
      if (isAuthenticated)
        (isLandlord ? const PanelPage() : const PerfilPage())
      else
        const SizedBox.shrink(),
    ];

    final effectiveIndex = (!isAuthenticated && _currentIndex == 3)
        ? 0
        : _currentIndex;

    return Scaffold(
      body: IndexedStack(index: effectiveIndex, children: pages),
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
            currentIndex: effectiveIndex,
            onTap: (index) {
              if (index == 3 && authProvider.user == null) {
                GuestAccessGuard.requireAuth(
                  context,
                  reason: GuestRedirectReason.profile,
                  sourcePath: '/home',
                );
                return;
              }
              setState(() {
                _currentIndex = index;
              });
              if (index == 3) {
                _syncReputationForCurrentUser();
              }
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
