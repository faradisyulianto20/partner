import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/profile_service.dart';
import 'package:hackathon/core/models/profile_models.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late final ProfileService _profileService = ProfileService(
    ApiClient(baseUrl: 'http://10.72.12.108:3000'),
  );

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
  final TextEditingController _birthDateController = TextEditingController(
    text: '20 Juni 2005',
  );
  File? _profileImage;
  String? _profileImageUrl;
  String _selectedGender = 'MALE';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

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

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted) {
      context.go('/onboarding/welcome');
    }
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
            const SizedBox(height: 16),
            _SectionLabel(text: 'Jenis Kelamin'),
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
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F4C7A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text(
                  'Edit Data Diri',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF1A99E)),
                  backgroundColor: const Color(0xFFFDECEA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Color(0xFFDE6A5A)),
                label: const Text(
                  'Keluar Akun',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDE6A5A),
                  ),
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

  const _LabeledField({
    required this.label,
    required this.controller,
    this.icon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
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
