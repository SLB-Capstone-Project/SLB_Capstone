import 'package:flutter/material.dart';
//import 'home_page.dart';
import 'login_files/login_screen.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';
import 'inventory_files/provider.dart' as inventory_provider;
//import 'camera_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: MaterialApp(title: 'SLB APP', home: LoginScreen(),),
      create: (context) => inventory_provider.UserProducts(),
      //child: MaterialApp(title: 'SLB APP', home: HomePage(),)
    );
  }
}
