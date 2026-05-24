import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Alex Ferguson',
  );
  final TextEditingController _usernameController = TextEditingController(
    text: '@alexfer321',
  );
  final TextEditingController _bioController = TextEditingController(
    text:
        'Hai aku adalah orang baik yang suka menolong tidak suka memerintah, perhatian, dan hobi olahraga dan bermain musik',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'alexferguso76@gmail.com',
  );
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D79A6),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _ProfilePhoto(imageFile: _profileImage, onTap: _pickImage),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'Nama Tampilan',
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Username',
                controller: _usernameController,
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Bio',
                controller: _bioController,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email_outlined,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const _ProfilePhoto({required this.imageFile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1F4C7A)),
                color: const Color(0xFFE7EDF5),
                image: imageFile != null
                    ? DecorationImage(
                        image: FileImage(imageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageFile == null
                  ? const Icon(Icons.person, size: 60, color: Color(0xFF9BAFC5))
                  : null,
            ),
            Positioned(
              right: -10,
              bottom: -10,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F4C7A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Foto Profil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F4C7A),
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final int maxLines;
  final bool readOnly;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.icon,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F4C7A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly ? const Color(0xFF9BAFC5) : const Color(0xFF1F4C7A),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF1F4C7A))
                : null,
            hintText: label == 'Bio' ? 'Ceritakan tentangmu' : null,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF0F2F6) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFD0E6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFD0E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1F4C7A)),
            ),
          ),
        ),
      ],
    );
  }
}
