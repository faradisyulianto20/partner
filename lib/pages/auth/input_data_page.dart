import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class InputDataPage extends StatefulWidget {
  const InputDataPage({super.key});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  final _usernameController = TextEditingController();
  final _tanggalController = TextEditingController();
  String? _selectedGender;
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF194F78),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _tanggalController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}';
    }
  }

  final LinearGradient horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF578BB3),
      Color(0xFF194F78),
    ],
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF578BB3),
      body: Column(
        children: [
          // Top blue strip
          const SizedBox(height: 60),
          // White card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42),
                  topRight: Radius.circular(42),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Input Data Profile',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Avatar
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _pickedImage == null ? horizontalGradient : null,
                                image: _pickedImage != null
                                    ? DecorationImage(
                                        image: FileImage(_pickedImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _pickedImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Upload Foto',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF194F78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Username
                    Text(
                      'Username',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: GoogleFonts.nunito(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF578BB3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tanggal Lahir
                    Text(
                      'Tanggal Lahir',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tanggalController,
                      readOnly: true,
                      onTap: () => _pickDate(context),
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yy',
                        hintStyle: GoogleFonts.nunito(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF578BB3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Jenis Kelamin
                    Text(
                      'Jenis Kelamin',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _GenderButton(
                            label: 'Laki-laki',
                            selected: _selectedGender == 'Laki-laki',
                            onTap: () => setState(() => _selectedGender = 'Laki-laki'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GenderButton(
                            label: 'Perempuan',
                            selected: _selectedGender == 'Perempuan',
                            onTap: () => setState(() => _selectedGender = 'Perempuan'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Daftar Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: horizontalGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/'),
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                'Daftar',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF194F78) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF194F78),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF194F78),
            ),
          ),
        ),
      ),
    );
  }
}