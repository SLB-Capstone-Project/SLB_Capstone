import 'package:flutter/material.dart';
//import 'home_page.dart';
import 'login_files/login_screen.dart';
//import 'camera_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'SLB APP', home: LoginScreen(),);
  }
}
