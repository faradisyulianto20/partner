import 'package:flutter/material.dart';

class AIPartner extends StatelessWidget {
  const AIPartner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text('AI Partner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(alignment: Alignment.center,decoration: BoxDecoration(
    color: Colors.blueAccent,
    shape: BoxShape.circle,
  ), width: 96, height: 96, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: 
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          Icon(Icons.chat, color: Colors.white, size: 32,),
          SizedBox(height: 4),
Text('Chatbot', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
    ],),),
              SizedBox(width: 12),
              Container(alignment: Alignment.center,decoration: BoxDecoration(
    color: Colors.blueAccent,
    shape: BoxShape.circle,
  ), width: 96, height: 96, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: 
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          Icon(Icons.mic, color: Colors.white, size: 32,),
          SizedBox(height: 4),
Text('Voice Assistant', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
    ],),)
            ]
          )
      ],)
    );
  }
}
