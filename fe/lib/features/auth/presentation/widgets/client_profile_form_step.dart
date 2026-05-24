import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ClientProfileFormStep extends StatefulWidget {
  final VoidCallback onSubmit;
  final String submitLabel;

  const ClientProfileFormStep({
    super.key,
    required this.onSubmit,
    this.submitLabel = 'Daftar',
  });

  @override
  State<ClientProfileFormStep> createState() => _ClientProfileFormStepState();
}

class _ClientProfileFormStepState extends State<ClientProfileFormStep> {
  final _usernameController = TextEditingController();
  final _tanggalController = TextEditingController();
  String? _selectedGender;
  File? _pickedImage;

  final LinearGradient _horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

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

  @override
  void dispose() {
    _usernameController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    gradient: _pickedImage == null ? _horizontalGradient : null,
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(_pickedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedImage == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
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
          decoration: _inputDecoration('Username'),
        ),
        const SizedBox(height: 16),
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
          decoration: _inputDecoration('dd/mm/yy'),
        ),
        const SizedBox(height: 16),
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
        Container(
          decoration: BoxDecoration(
            gradient: _horizontalGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onSubmit,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    widget.submitLabel,
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
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: Colors.black38, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          border: Border.all(color: const Color(0xFF194F78), width: 1.5),
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
