import 'package:flutter/material.dart';
import 'package:vihomeapp/app/app.dart';
import 'package:vihomeapp/env/env_def.dart';

void main() {
  EnvDef.title = 'Development';
  runApp(const FlavorApp());
}
