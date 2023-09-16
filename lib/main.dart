import 'Presentation/View/calculator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.white10,
        ),
        scaffoldBackgroundColor: Colors.black,
        primaryTextTheme: const TextTheme(
            titleLarge: TextStyle(
                color: Colors.lightBlueAccent
            ),
        ),
      ),
      home: const Calculator(),
    );
  }
}
