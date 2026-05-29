import 'package:shared_preferences/shared_preferences.dart';

/// Singleton yang menyimpan state autentikasi user.
/// Semua data auth disimpan di SharedPreferences.
class AuthState {
  static const _keyToken = 'custom_access_token';
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'user_email';
  static const _keyDisplayName = 'user_display_name';
  static const _keyRole = 'user_role';

  String? _token;
  String? _userId;
  String? _email;
  String? _displayName;
  String? _role;

  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get displayName => _displayName;
  String? get role => _role;

  /// True jika user sudah login (ada access token tersimpan)
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// True jika role user adalah PSYCHOLOGIST
  bool get isPsychologist => _role == 'PSYCHOLOGIST';

  /// Nama tampilan: prioritas displayName, fallback email
  String get displayNameOrEmail =>
      (_displayName != null && _displayName!.isNotEmpty)
          ? _displayName!
          : (_email ?? 'User');

  /// Muat data auth dari SharedPreferences saat app startup.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_keyToken);
      _userId = prefs.getString(_keyUserId);
      _email = prefs.getString(_keyEmail);
      _displayName = prefs.getString(_keyDisplayName);
      _role = prefs.getString(_keyRole);
    } catch (_) {}
  }

  /// Simpan data login ke memory dan SharedPreferences.
  Future<void> login({
    required String token,
    required String userId,
    required String email,
    String? displayName,
    required String role,
  }) async {
    _token = token;
    _userId = userId;
    _email = email;
    _displayName = displayName;
    _role = role;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyEmail, email);
    if (displayName != null) {
      await prefs.setString(_keyDisplayName, displayName);
    }
    await prefs.setString(_keyRole, role);
  }

  /// Hapus semua data auth (logout).
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _email = null;
    _displayName = null;
    _role = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyDisplayName);
    await prefs.remove(_keyRole);
  }
}

/// Global singleton
final AuthState authState = AuthState();
