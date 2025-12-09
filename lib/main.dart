import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid){
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA2zO5PLEkURbxlju5TZHP5Zede47oZPnY",
            appId: "com.app.waiting_list",
            messagingSenderId: "466547409106",
            projectId: "waitinglist-6e18e"
        )
    );
  }
  else{
    await Firebase.initializeApp();

  }
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waiting List',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: SplashScreen(),
    );
  }
}
