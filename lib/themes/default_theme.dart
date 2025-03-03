import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final ThemeData defaultTheme = ThemeData(
  appBarTheme: _appBarTheme,
);

const AppBarTheme _appBarTheme = AppBarTheme(
  elevation: 1,
  backgroundColor: Color.fromARGB(255, 255, 176, 233),
  shadowColor: Colors.white,
  
  surfaceTintColor: Colors.transparent,
  centerTitle: true,
);
