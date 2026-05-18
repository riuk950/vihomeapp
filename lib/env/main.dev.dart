import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vihomeapp/core/utils/firebase_options.dart';
import '../infrastructure/services/push_notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../app/app.dart';
import '../core/di/injection_container.dart';
import '../env/env_def.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../core/ads/ad_manager.dart' as vihomeapp_ads;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_CO', null);
  await initializeDateFormatting('es', null);
  await dotenv.load(fileName: ".env.dev");
  EnvDef.title = dotenv.env['APP_NAME'] ?? 'Development';
  EnvDef.isDebugMode = dotenv.env['APP_DEBUG'] == 'true';

  // Configurar inyección de dependencias (incluye inicialización de Supabase)
  await setupDependencyInjection();

  // Inicialización de Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await PushNotificationService.initializeApp();
  } catch (e) {
    debugPrint("Firebase pendiente de configurarse en consola nativa: $e");
  }

  // Inicializar Google Mobile Ads
  await getIt<vihomeapp_ads.AdManager>().initialize();

  runApp(const FlavorApp());
}
