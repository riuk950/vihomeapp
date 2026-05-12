import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth_provider.dart';

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
    // Solicitar permisos de ubicación al inicio
    await _requestPermissions();
    await _checkAuthAndNavigate();
  }

  Future<void> _requestPermissions() async {
    // Solicitar permiso de ubicación
    await Permission.location.request();
    // Nota: Los permisos de notificación se solicitan en PushNotificationService.initializeApp()
    // que se llama en el main.
  }

  _checkAuthAndNavigate() async {
    // Esperar un momento para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;

    if (mounted) {
      if (isAuthenticated) {
        context.go('/home');
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
