import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/onboarding_state.dart';
import '../../../domain/usecases/onboarding/complete_onboarding_usecase.dart';
import '../../../domain/usecases/onboarding/get_onboarding_status_usecase.dart';
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
        // RF-1.3: Usuario existente con sesión activa tras actualización
        try {
          final getStatusUseCase = getIt<GetOnboardingStatusUseCase>();
          final status = await getStatusUseCase();
          if (!status.hasSeenOnboarding) {
            final completeUseCase = getIt<CompleteOnboardingUseCase>();
            await completeUseCase(
              reason: OnboardingCompletionReason.existingSession,
              step: 0,
            );
          }
        } catch (e) {
          debugPrint('Error comprobando/marcando onboarding para usuario autenticado: $e');
        }

        if (!mounted) return;
        final subscriptionProvider =
            Provider.of<SubscriptionProvider>(context, listen: false);
        await subscriptionProvider.initialize(authProvider.user?.id);
        if (mounted) context.go('/home');
      } else {
        // RF-1.1 & RF-1.2: Usuario sin sesión activa
        bool hasSeenOnboarding = false;
        try {
          final getStatusUseCase = getIt<GetOnboardingStatusUseCase>();
          final status = await getStatusUseCase();
          hasSeenOnboarding = status.hasSeenOnboarding;
        } catch (e) {
          debugPrint('Error al consultar estado de onboarding en splash: $e');
          // Respaldo determinista: mostrar onboarding si falla la lectura sin sesión (RF-8.3)
          hasSeenOnboarding = false;
        }

        if (mounted) {
          if (!hasSeenOnboarding) {
            context.go('/onboarding');
          } else {
            context.go('/login');
          }
        }
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
