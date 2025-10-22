import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vihomeapp/app/app.dart';
import 'package:vihomeapp/env/env_def.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.dev");
  EnvDef.title = dotenv.env['APP_NAME'] ?? 'Development';
  runApp(const FlavorApp());
}
