import 'package:anhi/screens/overview.dart';
import 'package:flutter/material.dart';

const ColorScheme darkColors = ColorScheme(
  brightness: Brightness.dark,
  background: Color(0xFF0A0A0A),
  onBackground: Colors.white,
  surface: Color(0xFF111111),
  onSurface: Colors.white,
  error: Colors.red,
  onError: Colors.white,
  primary: Color(0xFF4AE282),
  onPrimary: Colors.black,
  secondary: Color(0xFF4d5fd6),
  onSecondary: Colors.white,
);
const ColorScheme lightColors = ColorScheme(
  brightness: Brightness.light,
  background: Color(0xFFEEEEEE),
  onBackground: Colors.black,
  surface: Colors.white,
  onSurface: Colors.black,
  error: Colors.red,
  onError: Colors.white,
  primary: Color(0xFF4AE282),
  onPrimary: Colors.black,
  secondary: Color(0xFF4d5fd6),
  onSecondary: Colors.white,
);

void main() {
  runApp(const AnhiApp());
}

class AnhiApp extends StatelessWidget {
  const AnhiApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anhi',
      theme: ThemeData.from(colorScheme: lightColors),
      darkTheme: ThemeData.from(colorScheme: darkColors),
      home: const OverviewPage(),
    );
  }
}
