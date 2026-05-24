import 'package:flutter/material.dart';

import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/features/client/home/widgets/cta.dart';
import 'package:hackathon/features/client/home/widgets/history.dart';
import 'package:hackathon/features/client/home/widgets/today.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Header(
            userName: 'Dinda',
            greeting: 'Selamat Pagi',
            onProfileTap: () {
              // Navigate to profile
            },
          ),
          const SizedBox(height: 20),
          const HomeCTA(),
          const SizedBox(height: 20),
          const HomeHistory(),
          const SizedBox(height: 20),
          const HomeToday(
            emotion: 'Cemas Ringan', 
            message: '“Sepertinya kamu sedang merasa cukup lelah secara emosional hari ini. Tidak apa-apa jika semuanya terasa berat untuk sementara waktu. Kamu tidak harus menghadapi semuanya sendirian.”', 
            iconType: 'sad'
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add more content here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
