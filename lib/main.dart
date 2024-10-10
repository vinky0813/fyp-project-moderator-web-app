import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyp_moderator_web_app/pages/moderator_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBPjaSfM3f6PO-9wWJRXpT2o8g8FaREbTs',
        appId: '1:240403571417:android:052ea9ddb0b77149ae54c8',
        messagingSenderId: '240403571417',
        projectId: 'fyp-project-6a908',
        storageBucket: 'fyp-project-6a908.appspot.com',
      )
    );
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  final supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "";
  final supabaseAnonKey = dotenv.env["API_KEY"] ?? "";

  developer.log(supabaseUrl);
  developer.log(supabaseAnonKey);

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginModerators(),
    );
  }
}
