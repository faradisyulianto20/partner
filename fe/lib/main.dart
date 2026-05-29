import 'package:flutter/material.dart';

// Router
import 'package:hackathon/router.dart';

// Auth & DotEnv
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hackathon/core/services/auth_state.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  try {
    await dotenv.load(fileName: ".env");
    print("DotEnv berhasil dimuat!");
  } catch (e) {
    print("Gagal memuat DotEnv, pastikan file .env ada di aset pubspec.yaml: $e");
  }

  await authState.init();
  
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