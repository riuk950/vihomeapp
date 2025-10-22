import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vihomeapp/app/app.dart';
import 'package:vihomeapp/env/env_def.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final titleEnv = dotenv.env['TitleDev'];
  EnvDef.title = titleEnv ?? 'Development';
  runApp(const FlavorApp());
}
