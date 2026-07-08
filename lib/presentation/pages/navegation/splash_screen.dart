import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Los permisos de ubicación ya se solicitan bajo demanda en las páginas de mapas.
    // Los permisos de notificación se solicitan en PushNotificationService.initializeApp() en el main.
    await _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final startTime = DateTime.now();

    // Esperamos a que el AuthProvider esté completamente inicializado para evitar jank de transición
    if (!authProvider.isInitialized) {
      final completer = Completer<void>();
      void listener() {
        if (authProvider.isInitialized) {
          authProvider.removeListener(listener);
          completer.complete();
        }
      }
      authProvider.addListener(listener);
      await completer.future;
    }

    // Calculamos el tiempo restante para cumplir los 2 segundos mínimos de la animación del splash
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remainingDelay = 2000 - elapsed;
    if (remainingDelay > 0) {
      await Future.delayed(Duration(milliseconds: remainingDelay));
    }

    if (!mounted) return;

    final isAuthenticated = authProvider.isAuthenticated;
    if (mounted) {
      if (isAuthenticated) {
        final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
        await subscriptionProvider.initialize(authProvider.user?.id);
        if (mounted) context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o icono de la app
              SizedBox(
                width: 300,
                height: 300,
                child: Center(
                    widthFactor: 0.5,
                    heightFactor: 0.5,
                    child: Lottie.asset('assets/lottie/lottievihome.json')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
