import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePsychologistPage extends StatefulWidget {
  const ProfilePsychologistPage({super.key});

  @override
  State<ProfilePsychologistPage> createState() =>
      _ProfilePsychologistPageState();
}

class _ProfilePsychologistPageState extends State<ProfilePsychologistPage> {
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);
  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F4C7A), Color(0xFF0E3A63)],
  );

  bool _isActive = true;
  bool _isUploading = false;
  static final String _baseUrl = AppConstants.baseUrl;
  late final ApiClient _apiClient = ApiClient(baseUrl: _baseUrl, autoLoadToken: true);

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 512);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      final dataUri = 'data:image/jpeg;base64,$base64Str';

      final data = <String, dynamic>{
        'fullName': _psychologistData?['fullName'] ?? '',
        'phoneNumber': _psychologistData?['phoneNumber'] ?? '',
        'gender': _psychologistData?['gender'] ?? 'MALE',
        'location': _psychologistData?['location'] ?? '',
        'clinicName': _psychologistData?['clinicName'] ?? '',
        'specialization': _psychologistData?['specialization'] ?? '',
        'yearsExperience': _psychologistData?['yearsExperience'] ?? 0,
        'nik': _psychologistData?['nik'] ?? '',
        'strNumber': _psychologistData?['strNumber'] ?? '',
        'education': _psychologistData?['education']?.map((e) => e is Map ? (e['institution'] ?? '') : e.toString()).toList() ?? [],
        'photoUrl': dataUri,
      };

      final response = await _apiClient.post('/profile/psychologist', body: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<_ProfileOption> get _options => const [
    _ProfileOption(
      title: 'Edit Profil & Layanan',
      icon: Icons.person_outline,
      route: '/psychologist/profile/profile-service',
    ),
    _ProfileOption(
      title: 'Pengaturan Jadwal',
      icon: Icons.calendar_today,
      route: '/psychologist/profile/schedule',
    ),
    _ProfileOption(
      title: 'Riwayat Pendapatan',
      icon: Icons.account_balance_wallet_outlined,
      route: '/psychologist/profile/income',
    ),
    _ProfileOption(
      title: 'Ulasan',
      icon: Icons.star_border,
      route: '/psychologist/profile/review',
    ),
  ];

  static const String _psychologistId = '4a63c647-72f7-4cd7-8e45-476b6ffdd8f4';
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

        if (!mounted) return;
        setState(() {
          _psychologistData = data;
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
    _updateStatus(_psychologistData?['isAcceptingSessions'] ?? true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsetsGeometry.all(24),
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildOptionCard(),
                    const SizedBox(height: 18),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildProfileHeader() {
    final String? photoUrl = _psychologistData?['photoUrl'] as String?;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        gradient: _headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadPhoto,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage: _getImageProvider(photoUrl),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              if (_isUploading)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B517A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                )
              else ...[
                Positioned(
                  bottom: 6,
                  right: 38,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF46C37B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
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
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _psychologistData?['fullName'] ?? 'Nama Lengkap',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _psychologistData?['specialization'] ?? 'Spesialisasi',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('custom_access_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');

    if (!context.mounted) return;
    context.go('/login');
  }

  Future<void> _updateStatus(bool active) async {
    setState(() => _isActive = active);

    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/psychologist/me/status',
        body: {'isAcceptingSessions': active},
      );

      if (!mounted) return;

      if (response.isSuccess) {
        setState(() {
          _psychologistData = response.data;
        });
      }
    } catch (e) {
      debugPrint('Update status error: $e');
      setState(() => _isActive = !active);
    }
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _softBlue, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Aktif',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Menerima sesi konsultasi saat ini',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) => _updateStatus(value),

            activeThumbColor: Colors.white,
            activeTrackColor: _primaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,

            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              return Colors.transparent;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _softBlue, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: _options
            .asMap()
            .entries
            .map(
              (entry) => _buildOptionTile(
                entry.value,
                isLast: entry.key == _options.length - 1,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildOptionTile(_ProfileOption option, {required bool isLast}) {
    return InkWell(
      onTap: () => context.push(option.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : _softBlue,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Container(
              width: 34,
              height: 34,
              child: Icon(option.icon, color: _primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.title,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: _primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFF1A99E), width: 1.2),
          backgroundColor: const Color(0xFFFDECEA),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        icon: const Icon(Icons.logout, color: Color(0xFFDE6A5A)),
        label: Text(
          'Keluar Akun',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFDE6A5A),
          ),
        ),
      ),
    );
  }
}

class _ProfileOption {
  final String title;
  final IconData icon;
  final String route;

  const _ProfileOption({
    required this.title,
    required this.icon,
    required this.route,
  });
}
