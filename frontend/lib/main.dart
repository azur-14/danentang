  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:danentang/Screens/Customer/Login/Login_Screen.dart';
  import 'package:danentang/Screens/Customer/Login/Login_SignUp_Screen.dart';
  import 'package:danentang/Screens/Customer/Login/SignUp.dart';
  import 'package:danentang/Screens/Customer/User/profile_page.dart';
  import 'package:danentang/Screens/Customer/Home/home_screen.dart';
  import 'routes.dart';
  import 'package:danentang/models/user_model.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
      ChangeNotifierProvider(
        create: (context) => UserModel(
          isLoggedIn: true,
          userName: 'Diew Ne',
          gender: 'Nữ',
          dateOfBirth: 'xx/xx/xxxx',
          phoneNumber: 'xxxxxxxxxx',
          email: 'example@gmail.com',
          address: 'hhhdshdhhhhh',
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
        child: const MyApp(),
      ),
    );
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'E-Commerce App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFAFAFA),
        ),
      );
    }
  }