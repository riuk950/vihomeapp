import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Ui/pages/pages.dart';
import '../../env/env_def.dart';

final appRouter = GoRouter(
  debugLogDiagnostics: EnvDef.isDebugMode,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => HomePage(),
    ),
    // Rutas adicionales según el entorno
    if (EnvDef.isDevelopment) ...[
      // Rutas solo disponibles en desarrollo (ej: pantalla de debug, logs, etc.)
      GoRoute(
        path: '/debug',
        name: 'debug',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Debug Info')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Entorno: Desarrollo'),
                Text('API Base URL: ${EnvDef.apiBaseUrl}'),
                Text('API Version: ${EnvDef.apiVersion}'),
                Text('Debug Mode: ${EnvDef.isDebugMode}'),
              ],
            ),
          ),
        ),
      ),
    ],
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