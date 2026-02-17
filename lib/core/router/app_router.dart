import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:vihomeapp/presentation/pages/landlord/complete_landlord_profile_page.dart';
import 'package:vihomeapp/presentation/pages/landlord/informacion_personal_landlord_page.dart';
import 'package:vihomeapp/presentation/pages/location_picker_page.dart';
import 'package:vihomeapp/presentation/pages/pages.dart';
import 'package:vihomeapp/presentation/pages/propiedades/detalles_propiedades_page.dart';
import 'package:vihomeapp/presentation/pages/tenant/complete_tenant_profile_page.dart';
import 'package:vihomeapp/presentation/pages/tenant/detalle_solicitud_page.dart';
import 'package:vihomeapp/presentation/pages/tenant/informacion_personal_tenant_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/pages/landlord/detalle_solicitud_arrendador_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    debugLogDiagnostics: EnvDef.isDebugMode,
    initialLocation: '/',
    redirect: (context, state) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';
        final isGoingToSplash = state.matchedLocation == '/';
        final isAuthRoute = isGoingToLogin || isGoingToRegister;

        // Si no está autenticado y va a una ruta protegida
        if (!isAuthenticated && !isAuthRoute && !isGoingToSplash) {
          return '/login';
        }

        // Si está autenticado y va a login/register, redirigir a home
        if (isAuthenticated && isAuthRoute) {
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
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
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

          return DetallesPropiedadesPage(property: property);
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
        path: '/mapa',
        name: 'mapa',
        builder: (context, state) => const MapaPage(),
      ),
      GoRoute(
        path: '/location-picker',
        name: 'location-picker',
        builder: (context, state) => const LocationPickerPage(),
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
