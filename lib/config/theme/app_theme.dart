import 'package:flutter/material.dart';


const seedColor = Color.fromARGB(255, 255, 255, 255);

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,

    listTileTheme: ListTileThemeData(
      iconColor: seedColor,
    ),
  );
}