import 'package:flutter/material.dart';

class RecommendationPage1 extends StatelessWidget {
  const RecommendationPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendation'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Recommendation Page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
