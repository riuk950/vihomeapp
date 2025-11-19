import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/di/injection_container.dart';
import '../core/router/app_router.dart';
import '../env/env_def.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/property_provider.dart';

class FlavorApp extends StatelessWidget {
  const FlavorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<PropertyProvider>()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: EnvDef.isDevelopment,
            themeMode: ThemeMode.system,
            title: EnvDef.title,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
