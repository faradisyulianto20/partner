import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static final String _baseUrl = AppConstants.baseUrl;
  late final ApiClient _apiClient = ApiClient(baseUrl: _baseUrl, autoLoadToken: true);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isUploading = false;
  String? _errorMessage;
  String? _photoUrl;
  String _selectedGender = 'MALE';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _apiClient.close();
    super.dispose();
  }

  ImageProvider _getImageProvider(String? url) {
    if (url == null) return const AssetImage('assets/images/doctor1.png');
    if (url.startsWith('data:')) {
      final parts = url.split(',');
      if (parts.length == 2) {
        return MemoryImage(base64Decode(parts[1]));
      }
    }
    return NetworkImage(url);
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get('/profile/me/client');
      debugPrint('GET /profile/me/client — status: ${response.statusCode}');

      if (response.statusCode != 200 || response.data is! Map) {
        setState(() {
          _errorMessage = 'Gagal memuat profil.';
          _isLoading = false;
        });
        return;
      }

      final data = response.data as Map;
      final user = data['user'] is Map ? data['user'] as Map : <String, dynamic>{};

      setState(() {
        _nameController.text = (data['displayName'] ?? user['displayName'] ?? '').toString();
        _usernameController.text = (data['username'] ?? '').toString();
        _emailController.text = (user['email'] ?? '').toString();
        _photoUrl = data['photoUrl']?.toString();
        _selectedGender = data['gender']?.toString() ?? 'MALE';
        if (data['birthDate'] != null) {
          final bd = DateTime.tryParse(data['birthDate'].toString());
          if (bd != null) {
            _birthDateController.text = _formatDate(bd);
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('GET /profile/me/client error: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 512);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      final dataUri = 'data:image/jpeg;base64,$base64Str';

      final response = await _apiClient.post('/profile/client', body: {
        'username': _usernameController.text.trim(),
        'photoUrl': dataUri,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _photoUrl = dataUri);
        _showSnackBar('Foto profil berhasil diperbarui.');
      } else {
        _showSnackBar('Gagal mengunggah foto.');
      }
    } catch (e) {
      debugPrint('Upload photo error: $e');
      _showSnackBar('Terjadi kesalahan saat mengunggah foto.');
    }
    setState(() => _isUploading = false);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('custom_access_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    if (!mounted) return;
    context.go('/login');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleSave() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      _showSnackBar('Username harus diisi.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = <String, dynamic>{
        'username': username,
        'gender': _selectedGender,
      };

      final name = _nameController.text.trim();
      if (name.isNotEmpty) body['displayName'] = name;

      final email = _emailController.text.trim();
      if (email.isNotEmpty) body['email'] = email;

      if (_photoUrl != null && _photoUrl!.isNotEmpty) {
        body['photoUrl'] = _photoUrl;
      }

      if (_birthDateController.text.isNotEmpty) {
        final parsed = _tryParseBirthDate(_birthDateController.text);
        if (parsed != null) body['birthDate'] = parsed;
      }

      final response = await _apiClient.post('/profile/client', body: body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        _showSnackBar('Gagal menyimpan profil.');
        setState(() => _isSaving = false);
        return;
      }

      setState(() => _isEditing = false);
      _showSnackBar('Profil berhasil disimpan.');
    } catch (e) {
      debugPrint('POST /profile/client error: $e');
      _showSnackBar('Terjadi kesalahan.');
    }
    setState(() => _isSaving = false);
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

  String? _tryParseBirthDate(String formatted) {
    try {
      final parts = formatted.split(' ');
      if (parts.length != 3) return null;
      const months = {
        'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4,
        'Mei': 5, 'Juni': 6, 'Juli': 7, 'Agustus': 8,
        'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12,
      };
      final day = int.tryParse(parts[0]);
      final month = months[parts[1]];
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return null;
      return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
               ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _fetchProfile, child: const Text('Coba Lagi')),
                    const SizedBox(height: 12),
                    _buildLogoutButton(),
                  ],
                ),
              )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _ProfilePhoto(
                        imageProvider: _getImageProvider(_photoUrl),
                        onTap: _isUploading ? null : _pickAndUploadPhoto,
                        isUploading: _isUploading,
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Nama Tampilan',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        readOnly: !_isEditing,
                      ),
                      const SizedBox(height: 12),
                      _LabeledField(
                        label: 'Username',
                        controller: _usernameController,
                        icon: Icons.alternate_email,
                        readOnly: !_isEditing,
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
                              isSelected: _selectedGender == 'MALE',
                              onTap: _isEditing ? () => setState(() => _selectedGender = 'MALE') : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GenderButton(
                              label: 'Perempuan',
                              isSelected: _selectedGender == 'FEMALE',
                              onTap: _isEditing ? () => setState(() => _selectedGender = 'FEMALE') : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _LabeledField(
                        label: 'Tanggal Lahir',
                        controller: _birthDateController,
                        icon: Icons.calendar_month,
                        readOnly: !_isEditing,
                        onTap: _isEditing ? _pickBirthDate : null,
                      ),
                      const SizedBox(height: 18),
                      if (_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F4C7A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.save, size: 18),
                            label: Text(
                              _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _isEditing = true),
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
                        _buildLogoutButton(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
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
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDE6A5A)),
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  final ImageProvider imageProvider;
  final VoidCallback? onTap;
  final bool isUploading;

  const _ProfilePhoto({
    required this.imageProvider,
    this.onTap,
    this.isUploading = false,
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
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: isUploading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF1F4C7A)),
                    )
                  : null,
            ),
            if (onTap != null)
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
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
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
  final bool readOnly;
  final VoidCallback? onTap;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.icon,
    this.readOnly = true,
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
            filled: true,
            fillColor: readOnly ? const Color(0xFFF0F2F6) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
  final VoidCallback? onTap;

  const _GenderButton({
    required this.label,
    required this.isSelected,
    this.onTap,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }
}
