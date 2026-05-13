import 'package:flutter/material.dart';

import 'package:hackathon/widgets/home/home_header.dart';
import 'package:hackathon/widgets/home/home_cta.dart';

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
          HomeHeader(
            userName: 'Dinda',
            greeting: 'Selamat Pagi',
            onProfileTap: () {
              // Navigate to profile
            },
          ),
          const SizedBox(height: 20),
          const HomeCTA(),
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

