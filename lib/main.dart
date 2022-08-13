import 'package:flutter/material.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import 'auth/login.dart';

void main() => runApp(const MyApp());


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    Widget splashScreen = SplashScreenView(
      navigateRoute: const Login(),
      duration: 7000,
      imageSize: 300,
      imageSrc: 'images/logo.png',
      backgroundColor: Colors.white,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'African Spring Admin App',
      home: splashScreen,
    );
  }
}

