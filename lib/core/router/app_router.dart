import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../env/env_def.dart';
import '../../presentation/pages/pages.dart';
import '../../presentation/providers/auth_provider.dart';

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
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ruta no encontrada: ${state.uri}'),
            if (EnvDef.isDebugMode)
              Text('Error: ${state.error}'),
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

