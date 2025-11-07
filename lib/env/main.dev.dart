import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vihomeapp/app/app.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:vihomeapp/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.dev");
  EnvDef.title = dotenv.env['APP_NAME'] ?? 'Development';
  
  // Inicializar Supabase
  await SupabaseService.instance.initialize();
  
  runApp(const FlavorApp());
}
