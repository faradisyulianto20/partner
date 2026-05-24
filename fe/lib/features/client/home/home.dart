import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/shared_widgets/navbar.dart';
import 'package:hackathon/core/state/user_role_state.dart';

class Home extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const Home({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final bool isPsychologist = userRoleState.isPsychologist;

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
            isPsychologist: isPsychologist,
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
