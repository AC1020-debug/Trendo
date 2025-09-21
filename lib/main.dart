import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'amplifyconfig.dart';
import 'homepage.dart';
import 'auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Amplify.isConfigured) {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3(); 

    await Amplify.addPlugin(auth);
    await Amplify.addPlugin(storage);

    try {
      await Amplify.configure(amplifyconfig);
      print("Amplify configured successfully");
    } catch (e) {
      print("Error configuring Amplify: $e");
    }
  }

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
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}