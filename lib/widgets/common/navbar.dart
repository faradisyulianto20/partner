import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;


  const NavBar({
    super.key ,
    required this.currentIndex, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, -4),
                  blurRadius: 8,
                )
              ]
            ),

            child: Row(
              children: [
                Expanded(child: navItem(Icons.people, 'Partner', 0)),
                Expanded(child: navItem(Icons.chat, 'Konsultasi', 1)),
                Expanded(child: navItem(Icons.mood, 'Mood', 2)),
                Expanded(child: navItem(Icons.person, 'Profile', 3))
              ],
            )
    );
  }

                   
Widget navItem(IconData icon,String text, int index ) {
  bool isActive = currentIndex == index;

  return GestureDetector(
    onTap: () => onTap(index),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[500] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon, 
            color: isActive ? Colors.white : Colors.black,
            size: 24,
          ),
        ),
        SizedBox(height: 4),
        Text(text, style: TextStyle(
          color: isActive ? Colors.black : const Color.fromARGB(102, 0, 0, 0),
          fontSize: 12,
          fontWeight: FontWeight.bold
        ),)
      ]
    ),
  );
}
}

 