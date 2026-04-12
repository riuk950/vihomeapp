import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

// Esta función debe estar FUERA de cualquier clase para manejar notificaciones
// en segundo plano o cuando la app está cerrada completamente.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("📩 Mensaje en Background recibido: ${message.messageId}");
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initializeApp() async {
    if (Firebase.apps.isEmpty) {
      debugPrint('ℹ️ FCM no instanciado: faltan credenciales (flutterfire configure)');
      return;
    }

    // 1. Escuchar los mensajes en Background (app minimizada o cerrada)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Solicitar permisos (fundamental para iOS y para Android >= 13)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('ℹ️ FCM Permisos otorgados status: ${settings.authorizationStatus}');

    // 3. Escuchar los mensajes en Foreground (cuando la app está abierta en pantalla)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Mensaje recibido en Foreground!');
      debugPrint('Datos: ${message.data}');

      if (message.notification != null) {
        debugPrint('Notificación visible: ${message.notification?.title}');
        // TODO: Puedes añadir aquí lógica usando SnackBar o LocalNotifications para
        // mostrar un banner in-app visible para el usuario si está navegando por la app.
      }
    });

    // 4. (Opcional) Detectar cuando el token se refresque para actualizarlo en Supabase
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint("🔄 FCM Token ha sido refrescado: $newToken");
      // Aquí se podría guardar nuevamente el token en bd.
    });
  }

  static Future<String?> getToken() async {
    if (Firebase.apps.isEmpty) return null;

    try {
      String? token = await _messaging.getToken();
      debugPrint("🔑 FCM Token actual: $token");
      return token;
    } catch (e) {
      debugPrint('❌ Error obteniendo FCM token: $e');
      return null;
    }
  }
}
