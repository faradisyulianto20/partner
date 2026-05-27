// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class PersonalitySetupPage extends StatefulWidget {
//   const PersonalitySetupPage({super.key});

//   @override
//   State<PersonalitySetupPage> createState() => _PersonalitySetupPageState();
// }

// class _PersonalitySetupPageState extends State<PersonalitySetupPage> {
//   final List<Map<String, dynamic>> _traits = [
//     {'label': 'Introvert', 'icon': Icons.person_outline},
//     {'label': 'Ekstrovert', 'icon': Icons.people_outline},
//     {'label': 'Analitis', 'icon': Icons.analytics_outlined},
//     {'label': 'Kreatif', 'icon': Icons.brush_outlined},
//     {'label': 'Empatik', 'icon': Icons.favorite_outline},
//     {'label': 'Mandiri', 'icon': Icons.self_improvement},
//   ];
//   int? _selectedIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.go('/onboarding/goal-selection'),
//         ),
//         title: const Text('Kepribadian'),
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
//                 'Ceritakan tentang diri Anda',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Pilih kepribadian yang paling menggambarkan Anda',
//                 style: TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 24),
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 1.4,
//                   ),
//                   itemCount: _traits.length,
//                   itemBuilder: (context, i) {
//                     final selected = _selectedIndex == i;
//                     return GestureDetector(
//                       onTap: () => setState(() => _selectedIndex = i),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: selected ? Colors.blue : Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: selected ? Colors.blue : Colors.grey.shade300,
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               _traits[i]['icon'] as IconData,
//                               color: selected ? Colors.white : Colors.grey,
//                               size: 32,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _traits[i]['label'] as String,
//                               style: TextStyle(
//                                 color: selected ? Colors.white : Colors.black,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _selectedIndex == null
//                     ? null
//                     : () => context.go('/onboarding/initial-mood-check'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text('Lanjut', style: TextStyle(fontSize: 16)),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
