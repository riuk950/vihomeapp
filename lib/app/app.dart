import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/di/injection_container.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../env/env_def.dart';
import '../presentation/providers/auth_provider.dart';

class FlavorApp extends StatelessWidget {
  const FlavorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AuthProvider>(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: EnvDef.isDevelopment,
            theme: AppTheme().getTheme(),
            title: EnvDef.title,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
