import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ClientProfileFormStep extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSubmit;
  final String submitLabel;
  final bool isSaving;

  const ClientProfileFormStep({
    super.key,
    required this.onSubmit,
    this.submitLabel = 'Daftar',
    this.isSaving = false,
  });

  @override
  State<ClientProfileFormStep> createState() => _ClientProfileFormStepState();
}

class _ClientProfileFormStepState extends State<ClientProfileFormStep> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _tanggalController = TextEditingController();
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
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  String? _validate() {
    if (_usernameController.text.trim().isEmpty) return 'Username harus diisi.';
    if (_displayNameController.text.trim().isEmpty) return 'Nama tampilan harus diisi.';
    if (_selectedGender == null) return 'Pilih jenis kelamin.';
    return null;
  }

  void _handleSubmit() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final data = <String, dynamic>{
      'username': _usernameController.text.trim(),
      'displayName': _displayNameController.text.trim(),
      'email': _emailController.text.trim(),
      'gender': _selectedGender == 'Laki-laki' ? 'MALE' : 'FEMALE',
      'birthDate': _tanggalController.text.isNotEmpty ? _tanggalController.text : null,
    };
    if (_photoBase64 != null) {
      data['photoUrl'] = _photoBase64;
    }
    widget.onSubmit(data);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
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
        Text('Nama Tampilan', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _displayNameController, decoration: _inputDecoration('Nama panggilan anda')),
        const SizedBox(height: 16),
        Text('Email', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _emailController, decoration: _inputDecoration('email@domain.com')),
        const SizedBox(height: 16),
        Text('Username', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(controller: _usernameController, decoration: _inputDecoration('Username')),
        const SizedBox(height: 16),
        Text('Tanggal Lahir', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: _tanggalController,
          readOnly: true,
          onTap: () => _pickDate(context),
          decoration: _inputDecoration('yyyy-mm-dd'),
        ),
        const SizedBox(height: 16),
        Text('Jenis Kelamin', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _GenderButton(
              label: 'Laki-laki',
              selected: _selectedGender == 'Laki-laki',
              onTap: () => setState(() => _selectedGender = 'Laki-laki'),
            )),
            const SizedBox(width: 12),
            Expanded(child: _GenderButton(
              label: 'Perempuan',
              selected: _selectedGender == 'Perempuan',
              onTap: () => setState(() => _selectedGender = 'Perempuan'),
            )),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(gradient: _horizontalGradient, borderRadius: BorderRadius.circular(30)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isSaving ? null : _handleSubmit,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: widget.isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.submitLabel, style: GoogleFonts.nunito(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700)),
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
