import 'package:flutter/material.dart';

class Greetings extends StatelessWidget {
  const Greetings({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/img/mascot.svg', width: 142),
        SizedBox(width: 12),
        Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
             Text('Hi, Faradis Yulianto!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.left,),
             Text("Setiap hari adalah kesempatan baru untuk menjadi versi terbaik dari dirimu.", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic), textAlign: TextAlign.left,)
          ],
        ),
        )
      ],
    );
  }
}