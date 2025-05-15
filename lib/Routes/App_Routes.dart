import 'package:flutter/material.dart';
import 'package:try_space/src/Screens/RegisterPage.dart';
import 'package:try_space/src/Screens/ComparisonScreen.dart';
import 'package:try_space/src/Screens/TryOnScreen.dart';
import 'package:try_space/src/Screens/SignUpPage.dart';
import 'package:try_space/src/Screens/HomePage.dart';
import 'package:try_space/src/Screens/LoginPage.dart';



class AppRoutes {
  static const String signup = '/signup';
  static const String comparison = '/comparison';
  static const String tryon = '/tryon';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';


  static Map<String, WidgetBuilder> routes = {
        login: (context) => LoginPage(),
        register: (context) => RegisterPage(),
        home: (context) => HomePage(),
        signup: (context) => SignUpPage(),
        // comparison: (context) => ComparisonScreen(),
        // tryon: (context) => TryOnScreen()
  };
}
