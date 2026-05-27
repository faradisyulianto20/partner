import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/state/user_role_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Mengambil Client ID murni dari file .env
  static final String _webClientId = dotenv.env['WEB_CLIENT'] ?? '';
  static final String? _iosClientId = dotenv.env['IOS_CLIENT'];
  static final String? _androidClientId = dotenv.env['ANDROID_CLIENT'];

  // Opsional jika kamu membutuhkan konfigurasi Supabase langsung dari Env di page ini
  static final String _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  StreamSubscription<AuthState>? _authSubscription;
  String? _userId;
  bool _didNavigate = false;

  // Vertical gradient
  final LinearGradient verticalGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  // Horizontal gradient
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
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (data.session?.user != null && !_didNavigate) {
        _didNavigate = true;
        final user = data.session!.user;
        _markUserRegistered(user, userRoleState.isPsychologist ? 'psychologist' : 'user').whenComplete(() {
          _navigateAfterRegister();
        });
      }

      setState(() {
        _userId = data.session?.user.id;
      });
    });
  }

  Future<void> _markUserRegistered(User user, String role) async {
    // 1. Ambil metadata lama bawaan Google agar tidak terhapus
    final currentMetadata = user.userMetadata ?? {};

    try {
      // 2. Duplikat data lama dan tambahkan parameter kustom baru
      final updatedData = Map<String, dynamic>.from(currentMetadata);
      updatedData['is_registered'] = true;
      updatedData['role'] =
          role; // 👈 Menyuntikkan role ('user' atau 'psychologist')

      if (kDebugMode) {
        print('Sedang memperbarui metadata ke server dengan role: $role...');
      }

      // 3. Update ke server Supabase
      final response = await supabase.auth.updateUser(
        UserAttributes(data: updatedData),
      );

      if (kDebugMode) {
        print('✅ Sukses! Metadata saat ini: ${response.user?.userMetadata}');
      }

      // 4. Paksa refresh session lokal agar UI Flutter langsung mendeteksi perubahan
      await supabase.auth.refreshSession();
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Gagal memperbarui parameter role & metadata: $e');
      }
    }
  }

  Future<void> _navigateAfterRegister() async {
    try {
      await userRoleState.fetchRole();
    } catch (e) {
      if (kDebugMode) {
        print('fetchRole error: $e');
      }
    }

    if (!mounted) return;
    context.go('/input-data');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _nativeGoogleSignIn() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    try {
      await signIn.initialize(
        // Only pass iOS clientId on iOS. Android uses serverClientId.
        clientId: Platform.isIOS ? _iosClientId : null,
        serverClientId: _webClientId,
      );

      final googleAccount = await signIn.authenticate();
      if (googleAccount == null) {
        return;
      }

      final googleAuthentication = googleAccount.authentication;
      final idToken = googleAuthentication.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      rethrow;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _nativeGoogleSignIn();
      return;
    }

    await supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient activeHorizontalGradient = userRoleState.isPsychologist
        ? psychologistHorizontalGradient
        : horizontalGradient;
    return Scaffold(
      backgroundColor: const Color(0xFF194F78),
      body: Stack(
        children: [
          Column(
            children: [
              // Top blue section
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(gradient: horizontalGradient),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 92),
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
          // Bottom white section overlays the blue section
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1.9 / 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mulai Perjalanan Emosionalmu',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF294669),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Temukan dukungan emosional yang nyaman, aman,\ndan memahami dirimu',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 28),
                    // Google Signup Button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFDDDDDD),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          gradient: activeHorizontalGradient,
                        ),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          child: InkWell(
                            onTap: _handleGoogleSignIn,
                            borderRadius: BorderRadius.circular(27),

                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/google-icon.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Lanjut dengan Google',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      color: const Color(0xFF294669),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider,
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
