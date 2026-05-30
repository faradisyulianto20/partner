import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';

class ProfileService extends StatefulWidget {
  const ProfileService({super.key});

  @override
  State<ProfileService> createState() => _ProfileServiceState();
}

class _ProfileServiceState extends State<ProfileService> {
  final Color _softBlue = const Color(0xFF7DA0C4);
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _priceController = TextEditingController(text: '100000');
  static final String _baseUrl = AppConstants.baseUrl;
  late final ApiClient _apiClient = ApiClient(baseUrl: _baseUrl, autoLoadToken: true);
  String? _photoBase64;
  bool _isUploading = false;

  // Ganti _specialties yang hardcoded dengan getter
  List<String> get _allSpecialties {
    final apiTags =
        (_psychologistData?['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Gabungkan default + api tags, hilangkan duplikat
    return {
      'Stres',
      'Keluarga & Hubungan',
      'Pekerjaan & Karir',
      'Depresi',
      'Pengembangan Diri',
      'Gangguan Kecemasan',
      ...apiTags,
    }.toList();
  }

  final Set<String> _selectedSpecialties = {
  };

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (_selectedSpecialties.isEmpty) {
      _showSnackBar('Pilih minimal satu spesialisasi.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final rawEducation = _psychologistData?['education'];
      late List<String> educationList;
      if (rawEducation is List) {
        educationList = rawEducation.map((e) {
          if (e is Map) {
            final level = e['level']?.toString() ?? '';
            final institution = e['institution']?.toString() ?? '';
            return '${level.isNotEmpty ? '$level - ' : ''}$institution';
          }
          return e.toString();
        }).toList();
      } else {
        educationList = [];
      }

      final data = <String, dynamic>{
        'email': _psychologistData?['email'] ?? '',
        'fullName': _nameController.text.trim(),
        'phoneNumber': _psychologistData?['phoneNumber'] ?? '',
        'gender': _psychologistData?['gender'] ?? 'MALE',
        'location': _psychologistData?['location'] ?? '',
        'clinicName': _psychologistData?['clinicName'] ?? '',
        'specialization': _psychologistData?['specialization'] ?? '',
        'yearsExperience': _psychologistData?['yearsExperience'] ?? 0,
        'nik': _psychologistData?['nik'] ?? '',
        'strNumber': _psychologistData?['strNumber'] ?? '',
        'education': educationList,
        'clientsHandled': _psychologistData?['clientsHandled'] ?? 0,
        'bio': _aboutController.text.trim(),
        'tags': _selectedSpecialties.toList(),
        'isAcceptingSessions': _psychologistData?['isAcceptingSessions'] ?? true,
      };
      if (_photoBase64 != null) {
        data['photoUrl'] = _photoBase64;
      } else if (_psychologistData?['photoUrl'] != null) {
        data['photoUrl'] = _psychologistData?['photoUrl'];
      }

      final response = await _apiClient.post('/profile/psychologist', body: data);
      if (response.isSuccess) {
        if (!mounted) return;
        _showSnackBar('Perubahan berhasil disimpan.');
      } else {
        if (!mounted) return;
        _showSnackBar('Gagal menyimpan perubahan.');
      }
    } catch (e) {
      debugPrint('Save changes error: $e');
      if (!mounted) return;
      _showSnackBar('Terjadi kesalahan.');
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

      final rawEducation = _psychologistData?['education'];
      late List<String> educationList;
      if (rawEducation is List) {
        educationList = rawEducation.map((e) {
          if (e is Map) {
            final level = e['level']?.toString() ?? '';
            final institution = e['institution']?.toString() ?? '';
            return '${level.isNotEmpty ? '$level - ' : ''}$institution';
          }
          return e.toString();
        }).toList();
      } else {
        educationList = [];
      }

      final data = <String, dynamic>{
        'email': _psychologistData?['email'] ?? '',
        'fullName': _nameController.text.trim(),
        'phoneNumber': _psychologistData?['phoneNumber'] ?? '',
        'gender': _psychologistData?['gender'] ?? 'MALE',
        'location': _psychologistData?['location'] ?? '',
        'clinicName': _psychologistData?['clinicName'] ?? '',
        'specialization': _psychologistData?['specialization'] ?? '',
        'yearsExperience': _psychologistData?['yearsExperience'] ?? 0,
        'nik': _psychologistData?['nik'] ?? '',
        'strNumber': _psychologistData?['strNumber'] ?? '',
        'education': educationList,
        'clientsHandled': _psychologistData?['clientsHandled'] ?? 0,
        'bio': _aboutController.text.trim(),
        'tags': _selectedSpecialties.toList(),
        'isAcceptingSessions': _psychologistData?['isAcceptingSessions'] ?? true,
        'photoUrl': dataUri,
      };

      final response = await _apiClient.post('/profile/psychologist', body: data);
      if (response.isSuccess) {
        setState(() {
          _photoBase64 = dataUri;
          _psychologistData ??= {};
          _psychologistData!['photoUrl'] = dataUri;
        });
        _showSnackBar('Foto profil berhasil diperbarui.');
      } else {
        _showSnackBar('Gagal mengunggah foto.');
      }
    } catch (e) {
      debugPrint('Upload photo error: $e');
      _showSnackBar('Terjadi kesalahan.');
    }
    setState(() => _isUploading = false);
  }

  ImageProvider _getImageProvider(String? url) {
    if (_photoBase64 != null) {
      return MemoryImage(base64Decode(_photoBase64!.split(',').last));
    }
    if (url != null && url.startsWith('data:')) {
      final parts = url.split(',');
      if (parts.length == 2) {
        return MemoryImage(base64Decode(parts[1]));
      }
    }
    if (url != null) return NetworkImage(url);
    return const AssetImage('assets/images/doctor1.png');
  }

  Map<String, dynamic>? _psychologistData;

  Future<void> _fetchPsychologistProfile() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/profile/me/psychologist',
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final data = response.data;
        setState(() {
          _psychologistData = data;

          _nameController.text = data['fullName'] ?? '';
          _aboutController.text = data['bio'] ?? '';

          final tags =
              (data['tags'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toSet() ??
              {};
          _selectedSpecialties
            ..clear()
            ..addAll(tags);
        });
      } else {
        debugPrint('Fetch failed: status ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching psychologist profile: $e');
      debugPrint(stackTrace.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPsychologistProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B517A),
        elevation: 0,
        centerTitle: true,
        // ---- TAMBAHKAN KODE DI BAWAH INI ----
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new, // Ikon iOS back yang tipis dan bersih
            color: Colors.white, // Memaksa warna ikon menjadi putih
            size: 20, // Ukuran proporsional untuk ikon iOS back
          ),
          onPressed: () {
            Navigator.of(
              context,
            ).pop(); // Aksi untuk kembali ke halaman sebelumnya
          },
        ),
        // ------------------------------------
        title: Text(
          'Profil & Layanan',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePhoto(),
                const SizedBox(height: 20),
                _buildSectionTitle('Informasi Dasar'),
                const SizedBox(height: 12),
                _buildFieldLabel('Nama Lengkap & Gelar'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap tidak boleh kosong.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Spesialisasi'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSpecialties
    .map((item) => _buildSpecialtyChip(item))
    .toList(),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Tentang'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _aboutController,
                  hintText: 'Ceritakan tentang pendekatanmu',

                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Layanan & Harga'),
                const SizedBox(height: 12),
                _buildFieldLabel('Tarif Konsultasi (Per Sesi)'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _priceController,
                  hintText: '100000',
                  prefixText: 'Rp ',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tarif konsultasi tidak boleh kosong.';
                    }
                    final price = int.tryParse(value.replaceAll('.', ''));
                    if (price == null || price <= 0) {
                      return 'Masukkan tarif yang valid.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FA),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: _buildSaveButton(),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 42,
                  backgroundImage: _getImageProvider(_psychologistData?['photoUrl'] as String?),
                  backgroundColor: Colors.white,
                ),
              ),
              if (_isUploading)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B517A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                )
              else
                GestureDetector(
                  onTap: _pickAndUploadPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B517A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ubah Foto',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B517A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1B517A),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B517A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _softBlue)
            : null,
        prefixText: prefixText,
        prefixStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1B517A),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _softBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _softBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B517A), width: 1.3),
        ),
      ),
    );
  }

  Widget _buildSpecialtyChip(String label) {
    final isSelected = _selectedSpecialties.contains(label);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSpecialties.remove(label);
          } else {
            _selectedSpecialties.add(label);
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B517A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _softBlue, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF1B517A),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF1B517A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save, color: Colors.white, size: 18),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
