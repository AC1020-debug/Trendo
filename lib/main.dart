import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'homepage.dart';
import 'widget/draggable_chatbot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const TrendoApp());
}

class TrendoApp extends StatelessWidget {
  const TrendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trendo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          const HomePage(),   // all your app’s navigation
          const DraggableChatbot(), // global FAB
        ],
      ),
    );
  }
}
