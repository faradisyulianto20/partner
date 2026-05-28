import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

class DummyAuthService {
  static const String DUMMY_USER_ID = 'dummy-user-001';
  static const String DUMMY_PSYCHOLOGIST_ID = 'dummy-psychologist-001';
  static const String DUMMY_USER_EMAIL = 'dummyuser@hackathon.test';
  static const String DUMMY_PSYCHOLOGIST_EMAIL = 'dummypsych@hackathon.test';

  static Session? currentDummySession;

  /// Simulate login as regular user
  static Future<Session?> loginAsUser() async {
    try {
      final now = DateTime.now();
      // Create dummy session locally
      final dummySession = Session(
        accessToken: _generateDummyToken(DUMMY_USER_ID),
        tokenType: 'bearer',
        expiresIn: 3600,
        refreshToken: _generateDummyToken('refresh'),
        user: User(
          id: DUMMY_USER_ID,
          appMetadata: {'provider': 'dummy'},
          userMetadata: {
            'full_name': 'Dummy User',
            'name': 'Dummy User',
            'avatar_url': 'https://via.placeholder.com/150?text=User',
          },
          aud: 'authenticated',
          email: DUMMY_USER_EMAIL,
          emailConfirmedAt: now.toIso8601String(),
          phone: '',
          confirmedAt: now.toIso8601String(),
          lastSignInAt: now.toIso8601String(),
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        ),
      );

      print('✅ Logged in as DUMMY USER');
      print('User ID: $DUMMY_USER_ID');
      print('Email: $DUMMY_USER_EMAIL');

      currentDummySession = dummySession;
      return dummySession;
    } catch (e) {
      print('❌ Dummy user login failed: $e');
      return null;
    }
  }

  /// Simulate login as psychologist
  static Future<Session?> loginAsPsychologist() async {
    try {
      final now = DateTime.now();
      // Create dummy session locally
      final dummySession = Session(
        accessToken: _generateDummyToken(DUMMY_PSYCHOLOGIST_ID),
        tokenType: 'bearer',
        expiresIn: 3600,
        refreshToken: _generateDummyToken('refresh'),
        user: User(
          id: DUMMY_PSYCHOLOGIST_ID,
          appMetadata: {'provider': 'dummy'},
          userMetadata: {
            'full_name': 'Dr. Dummy Psychologist',
            'name': 'Dr. Dummy Psychologist',
            'avatar_url': 'https://via.placeholder.com/150?text=Psychologist',
          },
          aud: 'authenticated',
          email: DUMMY_PSYCHOLOGIST_EMAIL,
          emailConfirmedAt: now.toIso8601String(),
          phone: '',
          confirmedAt: now.toIso8601String(),
          lastSignInAt: now.toIso8601String(),
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        ),
      );

      print('✅ Logged in as DUMMY PSYCHOLOGIST');
      print('User ID: $DUMMY_PSYCHOLOGIST_ID');
      print('Email: $DUMMY_PSYCHOLOGIST_EMAIL');

      currentDummySession = dummySession;
      return dummySession;
    } catch (e) {
      print('❌ Dummy psychologist login failed: $e');
      return null;
    }
  }

  /// Generate a simple but valid-looking JWT token for testing
  /// Format: base64(header).base64(payload).base64(signature)
  static String _generateDummyToken(String subject) {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 1));

    // Header
    final header = {'alg': 'HS256', 'typ': 'JWT'};

    // Payload
    final payload = {
      'sub': subject,
      'iat': (now.millisecondsSinceEpoch / 1000).floor(),
      'exp': (expiresAt.millisecondsSinceEpoch / 1000).floor(),
      'aud': 'authenticated',
      'iss': 'dummy-issuer',
    };

    // Encode header and payload to base64
    final headerEncoded = base64Url
        .encode(utf8.encode(jsonEncode(header)))
        .replaceAll('=', '');
    final payloadEncoded = base64Url
        .encode(utf8.encode(jsonEncode(payload)))
        .replaceAll('=', '');

    // Create signature (simple HMAC-SHA256 with dummy secret)
    final message = '$headerEncoded.$payloadEncoded';
    final signature = crypto.sha256.convert(utf8.encode(message)).toString();
    final signatureEncoded = base64Url
        .encode(utf8.encode(signature))
        .replaceAll('=', '');

    return '$message.$signatureEncoded';
  }
}
