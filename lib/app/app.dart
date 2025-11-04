import 'package:flutter/material.dart';
import 'package:vihomeapp/config/config.dart';
import 'package:vihomeapp/config/router/app_router.dart';
import 'package:vihomeapp/env/env_def.dart';

class FlavorApp extends StatelessWidget {
  const FlavorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: EnvDef.isDevelopment,
      theme: AppTheme().getTheme(),
      title: EnvDef.title,
      routerConfig: appRouter,
    );
  }
}
