import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/models/doctor.dart';
import 'package:hackathon/widgets/common/badge.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          context.push('/konsultasi/doctor-detail', extra: doctor);
        },
      child: Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8 , 12, 8, 12),
        child: Row(
          children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    doctor.imageUrl,
                    fit: BoxFit.contain, // object-contain
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),),
                  Text(doctor.specialization, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  Row(children: [
                    BadgeText(icon: Icons.work_outline, text: doctor.experience),
                    SizedBox(width: 8),
                    BadgeText(icon: Icons.star, text: '${doctor.rating}%'),
                  ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text('Rp ${doctor.price}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),),
                    SizedBox(width: 8),
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                    ), child: Text('Konsultasi', style: TextStyle(color: Colors.white),), )
                  ],)
              ],
          ),
        ),
      ],),
    )));
  }
}