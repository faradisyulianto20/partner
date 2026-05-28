import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePsychologistPage extends StatefulWidget {
  const ProfilePsychologistPage({super.key});

  @override
  State<ProfilePsychologistPage> createState() =>
      _ProfilePsychologistPageState();
}

class _ProfilePsychologistPageState extends State<ProfilePsychologistPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);
  final LinearGradient _headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F4C7A), Color(0xFF0E3A63)],
  );

  bool _isActive = true;

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

  Widget _buildProfileHeader() {
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
              const SizedBox(height: 124), // Placeholder untuk ukuran avatar
              CircleAvatar(
                radius: 44,
                backgroundImage: const AssetImage('assets/images/doctor1.png'),
                backgroundColor: Colors.white,
              ),

              Positioned(
                bottom: 6, // Mengangkat lingkaran hijau ke atas (naik 4 piksel)
                right: 6,
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dr. Shinta Pratiwi S.Psi, M.Psi',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Psikolog Klinis',
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
            onChanged: (value) => setState(() => _isActive = value),

            // 1. Warna lingkaran saat AKTIF (Putih)
            activeThumbColor: Colors.white,
            // 2. Warna background saat AKTIF (Primary Color)
            activeTrackColor: _primaryColor,

            // 3. Warna lingkaran saat NON-AKTIF (Putih)
            inactiveThumbColor: Colors.white,
            // 4. Warna background saat NON-AKTIF (Abu-abu)
            inactiveTrackColor: Colors.grey.shade300,

            // 5. CRITICAL (Material 3 Fix): Menghilangkan border luar bawaan agar warna penuh
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              return Colors
                  .transparent; // Membuat border bawaan menjadi transparan
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
        onPressed: () async {
          await supabase.auth.signOut();
          if (!mounted) return;
          context.go('/onboarding/welcome');
        },
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
