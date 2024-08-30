import 'package:flutter/material.dart';
import 'package:my_new_app/authentication/login_screen.dart';
import 'package:my_new_app/controller/authentication_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp().then((value) {
    Get.put(AuthenticationController());
  });

  // Request notification permission if denied
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pet Dating App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.amber,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
    );
  }
}
