import 'package:flutter/material.dart';
import 'package:try_space/Routes/App_Routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:try_space/src/Screens/SplashScreen.dart';
import 'package:try_space/src/Screens/RegisterPage.dart'; // Make sure this path is correct


void main () async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: SplashScreen(),
    routes: AppRoutes.routes, 
    );
  }
}