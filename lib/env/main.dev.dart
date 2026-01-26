import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../app/app.dart';
import '../core/di/injection_container.dart';
import '../env/env_def.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.dev");
  EnvDef.title = dotenv.env['APP_NAME'] ?? 'Development';
  EnvDef.isDebugMode = dotenv.env['APP_DEBUG'] == 'true';

  // Configurar inyección de dependencias (incluye inicialización de Supabase)
  await setupDependencyInjection();

  runApp(const FlavorApp());
}
