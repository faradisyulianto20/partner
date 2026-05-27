import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;
  String _selectedGender = 'Laki-laki';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _hydrateFromOAuth();
  }

  void _hydrateFromOAuth() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final metadata = user.userMetadata ?? {};
    final displayName = (metadata['full_name'] ?? metadata['name'])
        ?.toString()
        .trim();
    if (displayName != null && displayName.isNotEmpty) {
      _nameController.text = displayName;
    }

    final username = metadata['username']?.toString();
    if (username != null && username.isNotEmpty) {
      _usernameController.text = username;
    }

    final bio = metadata['bio']?.toString();
    if (bio != null && bio.isNotEmpty) {
      _bioController.text = bio;
    }

    final gender = metadata['gender']?.toString();
    if (gender == 'Perempuan' || gender == 'Laki-laki') {
      _selectedGender = gender!;
    }

    final birthDate = metadata['birth_date']?.toString();
    if (birthDate != null && birthDate.isNotEmpty) {
      _birthDateController.text = birthDate;
    }

    if (user.email != null && user.email!.isNotEmpty) {
      _emailController.text = user.email!;
    }

    final avatar = (metadata['avatar_url'] ?? metadata['picture'])?.toString();
    if (avatar != null && avatar.isNotEmpty) {
      _profileImageUrl = avatar;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameController.text.trim(),
            'username': _usernameController.text.trim(),
            'bio': _bioController.text.trim(),
            'gender': _selectedGender,
            'birth_date': _birthDateController.text.trim(),
          },
        ),
      );
      if (!mounted) return;
      _showToast('Perubahan profil berhasil disimpan');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      _showToast('Gagal menyimpan perubahan: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade600
            : const Color(0xFF1F4C7A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
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
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _ProfilePhoto(
              imageFile: _profileImage,
              imageUrl: _profileImageUrl,
              onTap: _pickImage,
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Nama Tampilan',
              controller: _nameController,
              icon: Icons.person_outline,
              hintText: 'nama kamu',
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Username',
              controller: _usernameController,
              icon: Icons.alternate_email,
              hintText: '@username',
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Bio',
              controller: _bioController,
              maxLines: 4,
              hintText: 'Ceritakan tentangmu',
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email_outlined,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            const _SectionLabel(text: 'Jenis Kelamin'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GenderButton(
                    label: 'Laki-laki',
                    isSelected: _selectedGender == 'Laki-laki',
                    onTap: () => setState(() => _selectedGender = 'Laki-laki'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GenderButton(
                    label: 'Perempuan',
                    isSelected: _selectedGender == 'Perempuan',
                    onTap: () => setState(() => _selectedGender = 'Perempuan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Tanggal Lahir',
              controller: _birthDateController,
              icon: Icons.calendar_month,
              readOnly: true,
              onTap: _pickBirthDate,
              hintText: 'Kapan tanggal lahirmu?',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F4C7A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onTap;

  const _ProfilePhoto({
    required this.imageFile,
    required this.imageUrl,
    required this.onTap,
  });

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
                    : imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageFile == null && imageUrl == null
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
  final VoidCallback? onTap;
  final String? hintText;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.icon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.hintText,
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
          onTap: onTap,
          style: TextStyle(
            color: readOnly ? const Color(0xFF9BAFC5) : const Color(0xFF1F4C7A),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF1F4C7A))
                : null,
            hintText: hintText,
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

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F4C7A),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? const Color(0xFF1F4C7A) : Colors.white;
    final textColor = isSelected ? Colors.white : const Color(0xFF1F4C7A);
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: const BorderSide(color: Color(0xFFBFD0E6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }
}
