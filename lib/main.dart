import 'package:flutter/material.dart';
import 'package:hackathon/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {    
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF2F4F6),
        useMaterial3: true,
      ),
    );
  }
}
