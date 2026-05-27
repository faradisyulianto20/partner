import 'package:flutter/material.dart';

// Router
import 'package:hackathon/router.dart';

// Supabase & DotEnv
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  try {
    await dotenv.load(fileName: ".env");
    print("DotEnv berhasil dimuat!");
  } catch (e) {
    print("Gagal memuat DotEnv, pastikan file .env ada di aset pubspec.yaml: $e");
  }

  final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  
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