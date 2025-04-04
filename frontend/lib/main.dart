import 'package:danentang/Screens/Home/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'Screens/Login/Login_Screen.dart';
import 'Screens/Login/Login_SignUp_Screen.dart';
import 'Screens/Login/SignUp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,

      home: HomeScreen(),
    );
  }
}