// main.dart
import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(const TrendoApp());
}

class TrendoApp extends StatelessWidget {
  const TrendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trendo - Demand Forecasting',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}