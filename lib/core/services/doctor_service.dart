import 'package:hackathon/core/models/doctor.dart';

class DoctorService {
  Future<List<Doctor>> fetchDoctors() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      Doctor(
        id: 1,
        name: 'Dr. John Doe',
        specialization: 'Psikolog Klinis Dewasa',
        experience: '10 tahun',
        rating: 95,
        imageUrl: 'assets/images/doctor1.png',
        price: 200000
      ),
      Doctor(
        id: 2,
        name: 'Dr. Jane Smith',
        specialization: 'Psikolog Anak dan Remaja',
        experience: '8 tahun',
        rating: 90,
        imageUrl: 'assets/images/doctor1.png',
        price: 150000
      ),
      Doctor(
        id: 3,
        name: 'Dr. Emily Johnson',
        specialization: 'Psikolog Keluarga',
        experience: '12 tahun',
        rating: 92,
        imageUrl: 'assets/images/doctor1.png',
        price: 250000
      ),
      Doctor(
        id: 4,
        name: 'Dr. Michael Brown',
        specialization: 'Psikolog Klinis Dewasa',
        experience: '15 tahun',
        rating: 98,
        imageUrl: 'assets/images/doctor1.png',
        price: 300000
      ),
      Doctor(
        id: 5,
        name: 'Dr. Sarah Davis',
        specialization: 'Psikolog Anak dan Remaja',
        experience: '7 tahun',
        rating: 88,
        imageUrl: 'assets/images/doctor1.png',
        price: 10000
      )
  ];
  }
}
