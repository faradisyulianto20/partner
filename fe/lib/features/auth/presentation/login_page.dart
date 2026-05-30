import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/state/user_role_state.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailLoading = false;

  final LinearGradient horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  final LinearGradient psychologistHorizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1B517A), Color(0xFF0C2B53)],
  );

  @override
  void initState() {
    super.initState();
    // Cek apakah sudah ada token tersimpan, jika ya langsung navigasi
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExistingToken());
  }

  /// Jika sudah pernah login sebelumnya (token tersimpan di SharedPreferences),
  /// langsung arahkan user ke halaman yang sesuai tanpa perlu login ulang.
  Future<void> _checkExistingToken() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('custom_access_token');
    if (token == null || token.isEmpty) return;

    final role = prefs.getString('user_role') ?? '';
    userRoleState.isPsychologist = role == 'PSYCHOLOGIST';

    if (!mounted) return;
    final dest = userRoleState.isPsychologist ? '/psychologist/home' : '/home';
    context.go(dest);
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF194F78),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Login dengan email & password ke endpoint /auth/login backend.
  /// Menyimpan accessToken dan role ke SharedPreferences untuk digunakan
  /// sebagai Bearer token pada semua request berikutnya.
  Future<void> _loginWithEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showToast('Email dan password tidak boleh kosong.', isError: true);
      return;
    }

    if (_isEmailLoading) return;
    setState(() => _isEmailLoading = true);

    try {
      // Hapus token lama agar tidak dikirim ke endpoint /auth/login
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_access_token');

      final apiClient = ApiClient(
        baseUrl: AppConstants.baseUrl,
        autoLoadToken: false,
      );
      apiClient.authToken = null;

      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        body: {'email': email, 'password': password},
        parser: (json) {
          if (json is Map<String, dynamic>) return json;
          if (json is Map) return Map<String, dynamic>.from(json);
          return <String, dynamic>{};
        },
      );
      apiClient.close();

      print('Login request sent with email: $email');
      print(
        'Password length: ${password.length}',
      ); // Jangan print password asli
      print('Login response: ${response.statusCode} - ${response.data}');

      if (!response.isSuccess || response.data == null) {
        final msg =
            response.data?['message']?.toString() ??
            'Login gagal. Periksa email dan password.';
        _showToast(msg, isError: true);
        return;
      }

      final accessToken = response.data!['accessToken']?.toString();
      if (accessToken == null || accessToken.isEmpty) {
        _showToast('Token tidak ditemukan dalam response.', isError: true);
        return;
      }

      // Simpan token & user info ke SharedPreferences + authState
      final userMap = response.data!['user'];
      final role = userMap is Map ? (userMap['role']?.toString() ?? 'CLIENT') : 'CLIENT';
      final userId = userMap is Map ? (userMap['id']?.toString() ?? '') : '';
      final userEmail = userMap is Map ? (userMap['email']?.toString() ?? '') : '';
      final displayName = userMap is Map ? userMap['displayName']?.toString() : null;

      await authState.login(
        token: accessToken,
        userId: userId,
        email: userEmail,
        displayName: displayName,
        role: role,
      );
      userRoleState.isPsychologist = role == 'PSYCHOLOGIST';

      if (!mounted) return;
      _showToast('Login berhasil!', isError: false);

      final destination = userRoleState.isPsychologist
          ? '/psychologist/home'
          : '/home';
      context.go(destination);
    } catch (e) {
      if (mounted) {
        _showToast('Terjadi kesalahan: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: Colors.black38, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF578BB3)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient activeHorizontalGradient = userRoleState.isPsychologist
        ? psychologistHorizontalGradient
        : horizontalGradient;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF194F78),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(gradient: activeHorizontalGradient),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 92),
                      SvgPicture.asset(
                        'assets/images/logo/logo-partner.svg',
                        width: 163,
                        height: 200,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42),
                  topRight: Radius.circular(42),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(32, 36, 32, 52),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Selamat datang kembali, tempat dukunganmu telah menunggu',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF294669),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bantu lebih banyak orang merasa didengar, dipahami, dan tidak sendirian',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: const Color(0xFF294669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Email Field ──
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email'),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: const Color(0xFF294669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Password Field ──
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('Password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black38,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: const Color(0xFF294669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Login Button ──
                    Container(
                      decoration: BoxDecoration(
                        gradient: activeHorizontalGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isEmailLoading
                              ? null
                              : _loginWithEmailPassword,
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: _isEmailLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Masuk',
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Daftar ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: const Color(0xFF578BB3),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
