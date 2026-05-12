import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/widgets/common/navbar.dart';

class Home extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const Home({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: navigationShell,
            ),
          ),
          NavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ],
      ),
    );
  }
}
