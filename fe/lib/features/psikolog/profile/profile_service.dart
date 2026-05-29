import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSaving = false);
    _showSnackBar('Perubahan berhasil disimpan.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static const String _psychologistId = '4a63c647-72f7-4cd7-8e45-476b6ffdd8f4';
  static const String _baseUrl = 'https://partner-seven-phi.vercel.app';
  Map<String, dynamic>? _psychologistData;

  Future<void> _fetchPsychologistProfile() async {
    final uri = Uri.parse('$_baseUrl/psychologist/$_psychologistId');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final completeData = const JsonEncoder.withIndent('  ').convert(data);
        debugPrint('─────────────────────────────────────');
        debugPrint('Data         : {$completeData}');
        debugPrint('─────────────────────────────────────');
        debugPrint(
          'Auth State  : ${Supabase.instance.client.auth.currentSession != null ? 'Authenticated' : 'Unauthenticated'}',
        );
        debugPrint(
          'Session     : ${Supabase.instance.client.auth.currentSession != null ? 'Exists' : 'None'}',
        );
        debugPrint(
          'User Email  : ${Supabase.instance.client.auth.currentUser?.email ?? 'null'}',
        );
        debugPrint('─────────────────────────────────────');
        setState(() {
          // ← tambah ini
          _psychologistData = data;

          _nameController.text = data['fullName'] ?? '';
          _aboutController.text = data['bio'] ?? '';

          // Populate selected specialties dari tags
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
        debugPrint(
          'Fetch failed: status ${response.statusCode} — ${response.body}',
        );
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
                  backgroundImage: const AssetImage(
                    'assets/images/doctor1.png',
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B517A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
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
