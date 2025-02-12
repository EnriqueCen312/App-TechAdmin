import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primaryColor = Color(0xffBAE162);
  static const Color darkBlue = Color.fromARGB(255, 4, 227, 243);
  static const Color darkerBlue = Color.fromARGB(255, 22, 134, 209);
  static const Color darkestBlue = Color.fromARGB(255, 27, 2, 255);

  static const List<Color> defaultGradient = [
    darkBlue,
    darkerBlue,
    darkestBlue,
  ];
}
