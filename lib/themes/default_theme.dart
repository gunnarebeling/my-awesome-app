import 'package:flutter/material.dart';

final ThemeData defaultTheme = ThemeData(
  appBarTheme: _appBarTheme,
);

const AppBarTheme _appBarTheme = AppBarTheme(
  elevation: 1,
  shadowColor: Colors.black,
  surfaceTintColor: Colors.transparent,
  centerTitle: true,
);
