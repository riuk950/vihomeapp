import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'supabase_service.dart';
import '../../core/router/app_router.dart';

// Esta función debe estar FUERA de cualquier clase para manejar notificaciones
// en segundo plano o cuando la app está cerrada completamente.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("📩 Mensaje en Background recibido: ${message.messageId}");
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Canal de alta importancia para Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'Notificaciones de ViHome', // title
    description: 'Este canal se usa para notificaciones importantes.',
    importance: Importance.max,
  );

  /// Callback opcional para manejar la navegación cuando el usuario toca una notificación.
  /// Se puede configurar desde la capa de presentación.
  static void Function(RemoteMessage message)? onNotificationTapped;

  static Future<void> initializeApp() async {
    if (Firebase.apps.isEmpty) {
      debugPrint(
          'ℹ️ FCM no instanciado: faltan credenciales (flutterfire configure)');
      return;
    }

    // 1. Inicializar Notificaciones Locales
    await _initLocalNotifications();

    // 2. Escuchar los mensajes en Background (app minimizada o cerrada)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Solicitar permisos (fundamental para iOS y para Android >= 13)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'ℹ️ FCM Permisos otorgados status: ${settings.authorizationStatus}');

    // 4. Escuchar los mensajes en Foreground (cuando la app está abierta en pantalla)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Mensaje recibido en Foreground!');
      debugPrint('Datos: ${message.data}');

      if (message.notification != null) {
        debugPrint('Notificación visible: ${message.notification?.title}');
        
        // Mostrar notificación local en Foreground
        _showLocalNotification(message);
      }
    });

    // 5. Manejar cuando el usuario toca una notificación (app en background/minimizada)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 Notificación tocada (app en background): ${message.data}');
      _handleNotificationNavigation(message);
    });

    // 6. Detectar cuando el token se refresque para actualizarlo en Supabase
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 FCM Token ha sido refrescado: $newToken");
      await _syncRefreshedToken(newToken);
    });
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Crear el canal en Android
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Manejar toque en la notificación local (Foreground)
        if (response.payload != null) {
          debugPrint('📲 Notificación local tocada: ${response.payload}');
          _navigateByType(response.payload);
        }
      },
    );
  }

  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: _channel.importance,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // Pasar la data como payload para recuperarla al tocar
        payload: message.data['type'], 
      );
    }
  }

  /// Procesa la notificación que abrió la app (si existe).
  /// Debe llamarse cuando el router y el contexto estén listos.
  static Future<void> handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('📲 App abierta desde notificación: ${initialMessage.data}');
      _handleNotificationNavigation(initialMessage);
    }
  }

  static void _handleNotificationNavigation(RemoteMessage message) {
    // Si hay un callback personalizado, lo llamamos.
    onNotificationTapped?.call(message);

    // Navegación automática basada en el tipo de notificación.
    // El payload debe contener un campo 'type'.
    final data = message.data;
    if (data.isEmpty) {
      debugPrint('⚠️ Notificación no contiene datos (payload vacío)');
      return;
    }

    final String? type = data['type'];
    debugPrint('ℹ️ Tipo de notificación detectado: $type');

    _navigateByType(type);
  }

  static void _navigateByType(String? type) {
    if (type == 'landlord_notification' || type == 'landlord_application') {
      appRouter.push('/notifications_landlord');
    } else if (type == 'tenant_notification' || type == 'tenant_application') {
      appRouter.push('/notifications_tenant');
    } else {
      debugPrint('⚠️ Tipo de notificación desconocido: $type');
    }
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

  /// Sincroniza un token refrescado con la tabla profiles en Supabase.
  static Future<void> _syncRefreshedToken(String newToken) async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;
      if (user != null) {
        final userId = user.id;

        // Sincronizar únicamente en la tabla general 'profiles'
        await client.from('profiles').upsert({
          'id': userId,
          'fcm_token': newToken,
        });

        debugPrint("✅ Token refrescado sincronizado únicamente en profiles");
      }
    } catch (e) {
      debugPrint("❌ Error al sincronizar token refrescado: $e");
    }
  }
}
