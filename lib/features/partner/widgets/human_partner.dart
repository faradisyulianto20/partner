import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HumanPartner extends StatefulWidget {
  final VoidCallback? onStartChat;
  const HumanPartner({super.key, this.onStartChat});

  @override
  _HumanPartnerState createState() => _HumanPartnerState();
}

class _HumanPartnerState extends State<HumanPartner> {

  String selectedPartner = '';
  String selectedMood = '';
  int step = 0;

  void choosePartner(String partner) {
    setState(() {
      selectedPartner = partner;
      step = 1;
    });
  }

  void chooseMood(String mood) {
    setState(() {
      selectedMood = mood;
      step = 2;
    });
    startLoading();
  }

  void startLoading() {
    Future.delayed(Duration(seconds: 5), () {
      if (!mounted) return;

      setState(() {
        step = 3;
      });
      
    });
  }

  String getTitle() {
    if (step == 0) {
      return 'Pilih Partner';
    } else if (step == 1) {
      return 'Pilih Mood';
    } else if (step == 2) {
      return 'Mencari Partner..';
    } else if (step == 3) {
      return 'Partner Ditemukan!';
    }
    else {
      return 'Summary';
    }
  }

  Widget buildContent() {
    if (step == 0) {
      return buildChoosePartner();
    } else if (step == 1) {
      return buildChooseMood();
    } else if (step == 2) {
      return buildLoading();
    } else if (step == 3) {
      return buildApproveParnter();
    } else {
      return Text('Summary: Partner - $selectedPartner, Mood - $selectedMood', style: TextStyle(color: Colors.white),);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 2),
      color: Colors.blueAccent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getTitle(),
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            buildContent(),
          ],
          ),
        ),
      );
  }

  Widget buildChoosePartner() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        buildButton('Didengar', 'Didengar'),
        buildButton('Curhat', 'Curhat'),
        buildButton('Cari teman ngobrol santai', 'Cari teman ngobrol santai'),
      ],
    );
  }

  Widget buildChooseMood() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        buildButton('Happy', 'Happy'),
        buildButton('Sad', 'Sad'),
        buildButton('Stressed', 'Stressed'),
      ],
    );
  }

  Widget buildApproveParnter() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
          buildButton('Mulai Chat', 'Mulai Chat'),
          buildButton('Cari Partner Lain', 'Cari Partner Lain')
        ],
      );
  }

  Widget buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.white,),
        SizedBox(height: 16),
        Text('Mencari Partner...', style: TextStyle(color: Colors.white, fontSize: 16),)
      ],
    );
  }

  Widget buildButton(String text, String onPressed) {
  return FilledButton(
    style: FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: StadiumBorder(),
      backgroundColor: Colors.white,
    ),
    onPressed: () {
      if (step == 0) {
        choosePartner(onPressed);
      } else if (step == 1) {
        chooseMood(onPressed);
      } else if (step == 3 && onPressed == 'Mulai Chat') {
        GoRouter.of(context).push('/partner/chat');
      } else if (step == 3 && onPressed == 'Cari Partner Lain') {
        setState(() {
          step = 2;
        });
        startLoading();
      }
    },
    child: Text(
      text,
      style: TextStyle(color: Colors.blue, fontSize: 12),
    ),
  );
}
}
