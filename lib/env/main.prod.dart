import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vihomeapp/core/utils/firebase_options.dart';
import '../infrastructure/services/push_notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../app/app.dart';
import '../core/di/injection_container.dart';
import '../env/env_def.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await PushNotificationService.initializeApp();
  } catch (e) {
    debugPrint("Firebase pendiente de configurarse en consola nativa: $e");
  }

  await initializeDateFormatting('es_CO', null);
  await initializeDateFormatting('es', null);
  await dotenv.load(fileName: ".env.prod");
  EnvDef.title = dotenv.env['APP_NAME'] ?? 'Production';
  EnvDef.isDebugMode = dotenv.env['APP_DEBUG'] == 'false';

  // Configurar inyección de dependencias (incluye inicialización de Supabase)
  await setupDependencyInjection();

  runApp(const FlavorApp());
}
