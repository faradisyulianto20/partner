// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hackathon/features/onboarding/widgets/mood_scanner.dart';

// class InitialMoodCheckPage extends StatefulWidget {
//   const InitialMoodCheckPage({super.key});

//   @override
//   State<InitialMoodCheckPage> createState() => _InitialMoodCheckPageState();
// }

// class _InitialMoodCheckPageState extends State<InitialMoodCheckPage> {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.go('/onboarding/personality-setup'),
//         ),
//         title: const Text('Mood Awal'),
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 16),
//               const Text(
//                 'Bagaimana perasaan Anda hari ini?',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Arahkan kamera ke wajah Anda untuk mendeteksi mood',
//                 style: TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 24),
//               const Expanded(child: MoodScanner()),
//               ElevatedButton(
//                 onPressed: () => context.go('/partner'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text('Mulai Perjalanan', style: TextStyle(fontSize: 16)),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
