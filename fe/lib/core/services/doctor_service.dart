import 'package:hackathon/core/models/doctor.dart';

class DoctorService {
  Future<List<Doctor>> fetchDoctors() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      Doctor(
        id: 1,
        name: 'Dr. Priantara, M.Psi',
        specialization: 'Psikolog Klinis Dewasa',
        location: 'Sleman, Yogyakarta',
        condition: 'Anxiety & Overthinking',
        rating: 4.9,
        imageUrl: 'assets/images/doctor1.png',
        price: 200000,
      ),
      Doctor(
        id: 2,
        name: 'Dr. Hayunaji, M.Psi',
        specialization: 'Psikolog Anak dan Remaja',
        location: 'Tangerang, Jakarta',
        condition: 'Burnout Recovery',
        rating: 4.7,
        imageUrl: 'assets/images/doctor1.png',
        price: 150000,
      ),
      Doctor(
        id: 3,
        name: 'Amanda, S.Psi, M.Psi',
        specialization: 'Psikolog Keluarga',
        location: 'Sleman, Yogyakarta',
        condition: 'Anxiety & Overthinking',
        rating: 4.9,
        imageUrl: 'assets/images/doctor1.png',
        price: 250000,
      ),
      Doctor(
        id: 4,
        name: 'Dr. Budi Utama, M.Psi',
        specialization: 'Psikolog Klinis Dewasa',
        location: 'Sleman, Yogyakarta',
        condition: 'Anxiety & Overthinking',
        rating: 4.9,
        imageUrl: 'assets/images/doctor1.png',
        price: 300000,
      ),
      Doctor(
        id: 5,
        name: 'Dr. Tirtadi, M.Psi',
        specialization: 'Psikolog Anak dan Remaja',
        location: 'Sleman, Yogyakarta',
        condition: 'Anxiety & Overthinking',
        rating: 4.9,
        imageUrl: 'assets/images/doctor1.png',
        price: 100000,
      ),
    ];
  }
}
