import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/domain/entities/project.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:vihomeapp/presentation/pages/pages.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// Rutas accesibles sin sesión activa (incluyendo exploración pública en modo invitado).
const Set<String> kPublicAppRoutes = {
  '/',
  '/onboarding',
  '/login',
  '/register',
  '/home',
  '/property-details',
  '/proyecto-detalle',
  '/mapa',
};

GoRouter createAppRouter({
  String initialLocation = '/',
  Listenable? refreshListenable,
}) {
  return GoRouter(
    observers: [appRouteObserver],
    debugLogDiagnostics: EnvDef.isDebugMode,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        var hasExpiredSession = false;
        try {
          hasExpiredSession = authProvider.hasExpiredSession;
        } catch (_) {}
        final location = state.matchedLocation;
        final isGoingToLogin = location == '/login';
        final isGoingToRegister = location == '/register';
        final isGoingToOnboarding = location == '/onboarding';
        final isPublicRoute = kPublicAppRoutes.contains(location);

        // Si no está autenticado y va a una ruta protegida (RF-5.1 / RF-1.7)
        if (!isAuthenticated && !isPublicRoute) {
          final reason = hasExpiredSession
              ? GuestRedirectReason.sessionExpired.wireValue
              : GuestRedirectReason.privateRoute.wireValue;
          if (hasExpiredSession) {
            authProvider.consumeSessionExpiredFlag();
          }
          return '/login?reason=$reason&from=${Uri.encodeComponent(location)}';
        }

        // Si expiró sesión estando en una ruta pública, transicionar a modo invitado (RF-1.7)
        if (!isAuthenticated && isPublicRoute && hasExpiredSession) {
          authProvider.consumeSessionExpiredFlag();
        }

        // Si está autenticado y va a login/register/onboarding, redirigir a home
        if (isAuthenticated &&
            (isGoingToLogin || isGoingToRegister || isGoingToOnboarding)) {
          return '/home';
        }
      } catch (e) {
        // Si el provider no está disponible aún, permitir continuar
        // El splash screen manejará la redirección
      }
      return null; // No redirigir
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          GuestRedirectContext? redirectContext;
          if (state.extra is GuestRedirectContext) {
            redirectContext = state.extra as GuestRedirectContext;
          } else {
            final reasonParam = state.uri.queryParameters['reason'];
            if (reasonParam != null && reasonParam.isNotEmpty) {
              final reason = GuestRedirectReason.fromWireValue(reasonParam);
              final sourcePath = state.uri.queryParameters['from'] ?? '/';
              redirectContext = GuestRedirectContext.fromReason(
                reason,
                sourcePath: sourcePath,
                canReturnToPreviousView: false,
              );
            }
          }
          return LoginPage(redirectContext: redirectContext);
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      // Rutas adicionales según el entorno
      if (EnvDef.isDevelopment)
        GoRoute(
          path: '/debug',
          name: 'debug',
          builder: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            return Scaffold(
              appBar: AppBar(title: const Text('Debug Info')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Entorno: Desarrollo'),
                    Text('API Base URL: ${EnvDef.apiBaseUrl}'),
                    Text('API Version: ${EnvDef.apiVersion}'),
                    Text('Debug Mode: ${EnvDef.isDebugMode}'),
                    const SizedBox(height: 20),
                    Text('Autenticado: ${authProvider.isAuthenticated}'),
                    if (authProvider.user != null)
                      Text('Usuario: ${authProvider.user!.email}'),
                  ],
                ),
              ),
            );
          },
        ),
      GoRoute(
        path: '/property-details',
        name: 'property-details',
        builder: (context, state) {
          final extra = state.extra;
          Property? property;

          if (extra is Property) {
            property = extra;
          } else if (extra is Map<String, dynamic>) {
            property = PropertyModel.fromJson(extra);
          }

          if (property == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Error: Propiedad no válida')),
            );
          }

          final user = Provider.of<AuthProvider>(context, listen: false).user;

          return DetallesPropiedadesPage(
            property: property,
            user: user,
          );
        },
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (context, state) => const CompleteTenantProfilePage(),
      ),
      GoRoute(
        path: '/complete-landlord-profile',
        name: 'complete-landlord-profile',
        builder: (context, state) => const CompleteLandlordProfilePage(),
      ),
      GoRoute(
        path: '/personal-info',
        name: 'personal-info',
        builder: (context, state) => const InformacionPersonalTenantPage(),
      ),
      GoRoute(
        path: '/personal-info-landlord',
        name: 'personal-info-landlord',
        builder: (context, state) => const InformacionPersonalLandlordPage(),
      ),
      GoRoute(
        path: '/mis-propiedades',
        name: 'mis-propiedades',
        builder: (context, state) => const MisPropiedadesPage(),
      ),
      GoRoute(
        path: '/solicitudes-arrendador',
        name: 'solicitudes-arrendador',
        builder: (context, state) => const SolicitudesArrendadorPage(),
      ),
      GoRoute(
        path: '/notifications_landlord',
        name: 'notifications_landlord',
        builder: (context, state) => const NotificationsLandlordPage(),
      ),
      GoRoute(
        path: '/notifications_tenant',
        name: 'notifications_tenant',
        builder: (context, state) => const NotificationsTenantPage(),
      ),
      GoRoute(
        path: '/detalle-solicitud-arrendador',
        name: 'detalle-solicitud-arrendador',
        builder: (context, state) {
          final application = state.extra as Application?;
          if (application == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Error: Solicitud no válida')),
            );
          }
          return DetalleSolicitudArrendadorPage(application: application);
        },
      ),
      GoRoute(
        path: '/solicitudes-arrendatario',
        name: 'solicitudes-arrendatario',
        builder: (context, state) => const SolicitudesArrendatarioPage(),
      ),
      GoRoute(
        path: '/crear-propiedad',
        name: 'crear-propiedad',
        builder: (context, state) => const CrearPropiedadPage(),
      ),
      GoRoute(
        path: '/editar-propiedad',
        name: 'editar-propiedad',
        builder: (context, state) {
          final extra = state.extra;
          Property? property;

          if (extra is Property) {
            property = extra;
          } else if (extra is Map<String, dynamic>) {
            property = PropertyModel.fromJson(extra);
          }

          if (property == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Error: Propiedad no válida')),
            );
          }

          return EditarPropiedadesPage(property: property);
        },
      ),
      GoRoute(
        path: '/mapa',
        name: 'mapa',
        builder: (context, state) {
          final tipo = state.uri.queryParameters['tipo'] ??
              (state.extra is Map
                  ? (state.extra as Map)['tipo'] as String?
                  : null);
          return MapaPage(tipo: tipo);
        },
      ),
      GoRoute(
        path: '/location-picker',
        name: 'location-picker',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return LocationPickerPage(
            initialLatitude: extra?['latitude'] as double?,
            initialLongitude: extra?['longitude'] as double?,
          );
        },
      ),
      GoRoute(
        path: '/solicitud-arriendo',
        name: 'solicitud-arriendo',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          if (extra == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Error: Datos no válidos')),
            );
          }
          return SolicitudDeArriendoPage(
            propertyId: extra['propertyId']!,
            propertyTitle: extra['propertyTitle']!,
            landlordId: extra['landlordId']!,
          );
        },
      ),
      GoRoute(
        path: '/detalle-solicitud',
        name: 'detalle-solicitud',
        builder: (context, state) {
          final application = state.extra as Application?;
          if (application == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Error: Solicitud no válida')),
            );
          }
          return DetalleSolicitudPage(application: application);
        },
      ),
      GoRoute(
        path: '/proyecto-detalle',
        name: 'proyecto-detalle',
        builder: (context, state) {
          final project = state.extra as Project?;
          if (project == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Error: Proyecto no válido')),
            );
          }
          return DetallesProyectoPage(project: project);
        },
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ruta no encontrada: ${state.uri}'),
            if (EnvDef.isDebugMode) Text('Error: ${state.error}'),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Crear el router después de que el provider esté disponible
final appRouter = createAppRouter();
