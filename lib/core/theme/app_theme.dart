import 'package:flutter/material.dart';

const primaryColor = Color.fromRGBO(23, 6, 218, 1);
const secondaryColor = Color.fromRGBO(0, 93, 255, 1);
const terceraColor = Color.fromRGBO(0, 134, 255, 1);
const cuartaColor = Color.fromRGBO(0, 165, 255, 1);
const quintaColor = Color.fromRGBO(0, 191, 227, 1);
const sextaColor = Color.fromRGBO(0, 255, 168, 1);
const backgroundColor = Color.fromRGBO(242, 242, 242, 1);
const textColor = Color.fromRGBO(0, 0, 0, 1);
const disabledColor = Color.fromRGBO(200, 200, 200, 1);

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    disabledColor: disabledColor,
    listTileTheme: ListTileThemeData(iconColor: primaryColor),
  );
}
