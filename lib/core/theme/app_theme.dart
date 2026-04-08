import 'package:flutter/material.dart';

const primaryColor = Color(0xFF0E4E82);
const secondaryColor = Color.fromRGBO(0, 93, 255, 1);
const terceraColor = Color.fromRGBO(0, 134, 255, 1);
const cuartaColor = Color.fromRGBO(0, 165, 255, 1);
const quintaColor = Color.fromRGBO(0, 191, 227, 1);
const sextaColor = Color.fromRGBO(0, 255, 168, 1);
const backgroundColor = Color(0xFFF6F7F8);
const textColor = Color.fromRGBO(0, 0, 0, 1);
const disabledColor = Color.fromRGBO(143, 143, 143, 1);

class AppTheme {
  static ThemeData get ligthTheme => ThemeData(
        fontFamily: 'Lato',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.light,
        primaryColor: primaryColor,
        //dialog theme
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: backgroundColor,
          titleTextStyle: const TextStyle(color: primaryColor, fontSize: 20),
          contentTextStyle: const TextStyle(color: textColor, fontSize: 16),
        ),
        //list tile theme
        listTileTheme: ListTileThemeData(iconColor: primaryColor),
        //app bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          titleTextStyle: const TextStyle(color: textColor, fontSize: 20),
        ),
        //elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        disabledColor: disabledColor,
        listTileTheme: ListTileThemeData(iconColor: primaryColor),
      );
}
