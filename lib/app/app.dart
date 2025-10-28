import 'package:flutter/material.dart';
import 'package:vihomeapp/config/config.dart';
import 'package:vihomeapp/env/env_def.dart';

class FlavorApp extends StatelessWidget {
  const FlavorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Material App Bar')),
        body: Center(child: Text('Hello World ${EnvDef.title}')),
      ),
    );
  }
}
