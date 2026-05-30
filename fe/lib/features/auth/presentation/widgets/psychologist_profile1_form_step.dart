import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Psychologist1Profile1FormStep extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onNext;
  final String submitLabel;

  const Psychologist1Profile1FormStep({
    super.key,
    required this.onNext,
    this.submitLabel = 'Lanjutkan',
  });

  @override
  State<Psychologist1Profile1FormStep> createState() =>
      _Psychologist1Profile1FormStepState();
}

class _Psychologist1Profile1FormStepState
    extends State<Psychologist1Profile1FormStep> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedGender;
  String? _photoBase64;

  final LinearGradient _horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 512);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  String? _validate() {
    if (_fullNameController.text.trim().isEmpty) return 'Nama lengkap harus diisi.';
    if (_emailController.text.trim().isEmpty) return 'Email harus diisi.';
    if (_teleponController.text.trim().isEmpty) return 'Nomor telepon harus diisi.';
    if (_selectedGender == null) return 'Pilih jenis kelamin.';
    if (_lokasiController.text.trim().isEmpty) return 'Lokasi harus diisi.';
    return null;
  }

  void _handleNext() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final data = <String, dynamic>{
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _teleponController.text.trim(),
      'gender': _selectedGender == 'Laki-laki' ? 'MALE' : 'FEMALE',
      'location': _lokasiController.text.trim(),
      'bio': _bioController.text.trim(),
    };
    if (_photoBase64 != null) {
      data['photoUrl'] = _photoBase64;
    }
    widget.onNext(data);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _lokasiController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Input Data Profile', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE7EDF5),
                  border: Border.all(color: const Color(0xFF194F78), width: 2),
                  image: _photoBase64 != null
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(_photoBase64!.split(',').last)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _photoBase64 == null
                    ? const Icon(Icons.person, size: 50, color: Color(0xFF9BAFC5))
                    : null,
              ),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF194F78),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Nama Lengkap', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _fullNameController, decoration: _inputDecoration('Nama lengkap')),
        const SizedBox(height: 16),
        Text('Email', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _emailController, decoration: _inputDecoration('email@domain.com')),
        const SizedBox(height: 16),
        Text('Nomor Telepon', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _teleponController, decoration: _inputDecoration('+62')),
        const SizedBox(height: 16),
        Text('Jenis Kelamin', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _GenderButton(label: 'Laki-laki', selected: _selectedGender == 'Laki-laki', onTap: () => setState(() => _selectedGender = 'Laki-laki'))),
            const SizedBox(width: 12),
            Expanded(child: _GenderButton(label: 'Perempuan', selected: _selectedGender == 'Perempuan', onTap: () => setState(() => _selectedGender = 'Perempuan'))),
          ],
        ),
        const SizedBox(height: 16),
        Text('Lokasi', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _lokasiController, decoration: _inputDecoration('Alamat lokasi')),
        const SizedBox(height: 16),
        Text('Bio', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _bioController, maxLines: 3, decoration: _inputDecoration('Ceritakan tentang diri anda')),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(gradient: _horizontalGradient, borderRadius: BorderRadius.circular(30)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleNext,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(widget.submitLabel, style: GoogleFonts.nunito(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700)),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF578BB3))),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderButton({required this.label, required this.selected, required this.onTap});

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
          child: Text(label, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF194F78))),
        ),
      ),
    );
  }
}
