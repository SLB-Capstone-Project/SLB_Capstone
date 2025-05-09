import 'package:flutter/material.dart';
//import 'home_page.dart';
import 'login_files/login_screen.dart';
import 'homepage_files/home_page.dart';
import 'package:provider/provider.dart';
import 'inventory_files/provider.dart' as inventory_provider;
import 'homepage_files/provider.dart' as history_provider;
//import 'camera_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => inventory_provider.UserProducts()),
        ChangeNotifierProvider(create: (context) => history_provider.UserHistory())
      ],
      //child: MaterialApp(title: 'SLB APP', home: HomePage(),)
      child: MaterialApp(title: 'SLB APP', home: LoginScreen(),),
    );
  }
}