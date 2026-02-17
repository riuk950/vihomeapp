import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import '../core/di/injection_container.dart';
import '../core/router/app_router.dart';
import '../env/env_def.dart';
import '../presentation/providers/providers.dart';

class FlavorApp extends StatelessWidget {
  const FlavorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<PropertyProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<TenantProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<LandlordProvider>()),
        ChangeNotifierProvider(
          create: (_) => getIt<LandlordPropertiesProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => getIt<ApplicationProvider>()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: EnvDef.isDebugMode,
            theme: AppTheme.ligthTheme,
            title: EnvDef.title,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
