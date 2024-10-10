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

  final apiKey = dotenv.env["FIREBASE_API_KEY"];
  final authDomain = dotenv.env["FIREBASE_AUTH_DOMAIN"];
  final projectId = dotenv.env["FIREBASE_PROJECT_ID"];
  final storageBucket = dotenv.env["FIREBASE_STORAGE_BUCKET"];
  final messagingSenderId = dotenv.env["FIREBASE_MESSAGING_SENDER_ID"];
  final appId = dotenv.env["FIREBASE_APP_ID"];
  final measurementId = dotenv.env["FIREBASE_MEASUREMENT_ID"];

  print(apiKey);
  print(authDomain);
  print(projectId);
  print(storageBucket);
  print(messagingSenderId);
  print(appId);
  print(measurementId);

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey!,
        authDomain: authDomain!,
        projectId: projectId!,
        storageBucket: storageBucket!,
        messagingSenderId: messagingSenderId!,
        appId: appId!,
        measurementId: measurementId!,
      ),
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
