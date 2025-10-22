import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vihomeapp/app/app.dart';
import 'package:vihomeapp/env/env_def.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  EnvDef.title = 'Development';
  // Ejemplo: leer una variable del .env
  final apiUrl = dotenv.env['API_URL'];
  print('API_URL desde .env: $apiUrl');
  runApp(const FlavorApp());
}
