import 'package:flutter/material.dart' show Color, MaterialColor;

class ColorUtils {
  static const primary = Color(0xFFaa7ff9);
  //  .fromARGB(255, 103, 19, 239);
  static const primarySwatch = MaterialColor(0xFFaa7ff9, color);
  static const textfieldFill = Color(0xA0f2f2f2);
  static const Map<int, Color> color = {
    50: Color.fromARGB(80, 234, 128, 252),
    100: Color.fromARGB(100, 170, 127, 249),
    200: Color.fromARGB(120, 170, 127, 249),
    300: Color.fromARGB(140, 170, 127, 249),
    400: Color.fromARGB(160, 170, 127, 249),
    500: Color.fromARGB(180, 170, 127, 249),
    600: Color.fromARGB(210, 170, 127, 249),
    700: Color.fromARGB(220, 170, 127, 249),
    800: Color.fromARGB(235, 170, 127, 249),
    900: Color.fromARGB(255, 170, 127, 249),
  };
}
