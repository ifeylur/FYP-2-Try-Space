import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:try_space/Routes/App_Routes.dart';
import 'package:try_space/src/Screens/SplashScreen.dart';
import 'package:try_space/Providers/UserProvider.dart';
import 'package:try_space/Providers/GarmentProvider.dart';
import 'package:try_space/Providers/TryOnResultProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;


  runApp(MyApp(isLoggedIn:isLoggedIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,required this.isLoggedIn});

  final bool isLoggedIn;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GarmentProvider()),
        ChangeNotifierProvider(create: (_) => TryOnResultProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue, // Replace this later with your gradient
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
        routes: AppRoutes.routes,
      ),
    );
  }
}
