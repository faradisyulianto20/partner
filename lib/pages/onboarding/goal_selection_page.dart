import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoalSelectionPage extends StatefulWidget {
  const GoalSelectionPage({super.key});

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> {
  final List<String> _goals = [
    'Mengurangi Stress',
    'Meningkatkan Mood',
    'Tidur Lebih Baik',
    'Membangun Kepercayaan Diri',
    'Mengelola Kecemasan',
    'Menemukan Keseimbangan Hidup',
  ];
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/welcome'),
        ),
        title: const Text('Pilih Tujuan'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Apa yang ingin Anda capai?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih satu atau lebih tujuan Anda',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_goals.length, (i) {
                    final selected = _selected.contains(i);
                    return FilterChip(
                      label: Text(_goals[i]),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        selected ? _selected.remove(i) : _selected.add(i);
                      }),
                    );
                  }),
                ),
              ),
              ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => context.go('/onboarding/personality-setup'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Lanjut', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}