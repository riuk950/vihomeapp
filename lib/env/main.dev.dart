import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../app/app.dart';
import '../core/di/injection_container.dart';
import '../env/env_def.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CO', null);
  await initializeDateFormatting('es', null);
  await dotenv.load(fileName: ".env.dev");
  EnvDef.title = dotenv.env['APP_NAME'] ?? 'Development';
  EnvDef.isDebugMode = dotenv.env['APP_DEBUG'] == 'true';

  // Configurar inyección de dependencias (incluye inicialización de Supabase)
  await setupDependencyInjection();

  runApp(const FlavorApp());
}
