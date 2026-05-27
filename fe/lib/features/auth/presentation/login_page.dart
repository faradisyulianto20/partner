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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  String get _webClientId => dotenv.env['WEB_CLIENT'] ?? '';
  String? get _iosClientId => dotenv.env['IOS_CLIENT'];

  // Isn't used because android use web client id for native sign in, but we can keep it for future use if needed
  // String? get _androidClientId => dotenv.env['ANDROID_CLIENT'];

  StreamSubscription<AuthState>? _authSubscription;
  bool _didNavigate = false;
  bool _isLoading = false;

  final LinearGradient verticalGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  final LinearGradient horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  @override
  void initState() {
    super.initState();
    _didNavigate = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectIfAlreadyLoggedIn();
    });

    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final user = session?.user;

      final accessToken = session?.accessToken;
      final refreshToken = session?.refreshToken;

      final safeAccess = (accessToken != null && accessToken.length > 50)
          ? '${accessToken.substring(0, 50)}...'
          : accessToken;

      // 🔒 Pemotongan Refresh Token yang aman (Penyembuh Crash!)
      final safeRefresh = (refreshToken != null && refreshToken.length > 20)
          ? '${refreshToken.substring(0, 20)}...'
          : refreshToken;

      // ═══════════════════════════════════════════
      // 🔍 SESSION LOGGING - Cek semua token & info
      // ═══════════════════════════════════════════
      print('╔══════════════════════════════════════╗');
      print('║        AUTH STATE CHANGE EVENT        ║');
      print('╚══════════════════════════════════════╝');
      print('Event      : ${data.event}');
      print('User ID    : ${user?.id ?? 'null'}');
      print('Email      : ${user?.email ?? 'null'}');
      print('Display Name: ${user?.userMetadata?['full_name'] ?? 'null'}');
      print('Avatar URL : ${user?.userMetadata?['avatar_url'] ?? 'null'}');
      print('Provider   : ${user?.appMetadata?['provider'] ?? 'null'}');
      print('─────────────────────────────────────');
      print('🎫 Access Token: $safeAccess');
      print('🔄 Refresh Token: $safeRefresh');
      print(
        'Expires At  : ${session?.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(session!.expiresAt! * 1000) : 'null'}',
      );
      print('Token Type  : ${session?.tokenType ?? 'null'}');
      print('─────────────────────────────────────');

      // Tampilkan user metadata lengkap
      if (user?.userMetadata != null) {
        print('User Metadata:');
        user!.userMetadata!.forEach((key, value) {
          print('   $key: $value');
        });
      }

      if (user?.appMetadata != null) {
        print('App Metadata:');
        user!.appMetadata.forEach((key, value) {
          print('   $key: $value');
        });
      }
      print('══════════════════════════════════════');

      if (user != null && !_didNavigate) {
        setState(() {
          _didNavigate = true; // Kunci segera di dalam setState
          _isLoading = false;
        });

        _showToast(
          'Login berhasil! Selamat datang, ${user.userMetadata?['full_name'] ?? user.email}',
          isError: false,
        );

        _navigateAfterLogin();
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _redirectIfAlreadyLoggedIn() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;

    if (user == null || _didNavigate || !mounted) return;

    setState(() {
      _didNavigate = true;
      _isLoading = true;
    });

    await _navigateAfterLogin();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _navigateAfterLogin() async {
    try {
      await userRoleState.fetchRole();
      print(
        'User Role: ${userRoleState.isPsychologist ? 'Psychologist' : 'Regular User'}',
      );
    } catch (e) {
      print('fetchRole error: $e');
    }

    if (mounted) {
      final destination = userRoleState.isPsychologist
          ? '/psychologist/home'
          : '/home';
      print('Navigating to: $destination');
      context.go(destination);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _nativeGoogleSignIn() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    print('Starting Native Google Sign In...');
    print('Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
    print(
      'Web Client ID: ${_webClientId.isNotEmpty ? '${_webClientId.substring(0, 20)}...' : 'EMPTY! ⚠️'}',
    );

    try {
      await signIn.initialize(
        clientId: Platform.isIOS ? _iosClientId : null,
        serverClientId: _webClientId,
      );

      print('GoogleSignIn initialized');

      final googleAccount = await signIn.authenticate();
      if (googleAccount.authentication.idToken == null) {
        print('User cancelled Google Sign In');
        _showToast('Login dibatalkan', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      print('Google Account: ${googleAccount.email}');
      print('Display Name: ${googleAccount.displayName}');

      final googleAuthentication = googleAccount.authentication;
      final idToken = googleAuthentication.idToken;

      print('─────────────────────────────────────');
      print(
        'Google ID Token    : ${idToken != null ? '${idToken.substring(0, 30)}... ✅' : 'NULL ❌'}',
      );
      print('─────────────────────────────────────');

      if (idToken == null) {
        throw 'No ID Token found. Pastikan Web Client ID sudah benar di Google Console!';
      }

      print('Sending idToken to Supabase...');
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      print('Supabase signInWithIdToken success!');
      print('Supabase User ID: ${response.user?.id}');
      print('Supabase Email  : ${response.user?.email}');
    } on GoogleSignInException catch (error) {
      print('GoogleSignInException: ${error.code} - ${error.description}');
      if (error.code == GoogleSignInExceptionCode.canceled) {
        setState(() => _isLoading = false);
        return;
      }
      _showToast('Google Sign In error: ${error.description}', isError: true);
      setState(() => _isLoading = false);
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      _showToast('Error: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    print('_handleGoogleSignIn called');
    print('kIsWeb: $kIsWeb');

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _nativeGoogleSignIn();
        return;
      }
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      print('_handleGoogleSignIn error: $e');
      if (mounted) {
        _showToast('Gagal login: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... widget tree tetap sama, hanya tambahkan loading indicator
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
                  decoration: BoxDecoration(gradient: verticalGradient),
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Selamat datang kembali di ruang amanmu',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lanjutkan perjalanan emosionalmu bersama\ndukungan yang memahami dirimu',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 42),
                      // Google Login Button dengan loading state
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
                            gradient: horizontalGradient,
                          ),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(27),
                            child: InkWell(
                              onTap: _isLoading ? null : _handleGoogleSignIn,
                              borderRadius: BorderRadius.circular(27),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: _isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/google-icon.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Masuk dengan Google',
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w700,
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
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFDDDDDD),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Belum memiliki akun? Daftar terlebih dahulu',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFDDDDDD),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: horizontalGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.go('/register'),
                            borderRadius: BorderRadius.circular(30),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  'Daftar',
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
