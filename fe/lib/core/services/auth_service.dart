import 'package:hackathon/core/models/api_response.dart';
import 'package:hackathon/core/models/auth_models.dart';
import 'package:hackathon/core/services/api_client.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) {
    return _client.post(
      '/auth/login',
      body: request.toJson(),
      parser: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<RegisterResponse>> register(RegisterRequest request) {
    return _client.post(
      '/auth/register',
      body: request.toJson(),
      parser: (json) => RegisterResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<RefreshTokenResponse>> refreshToken(
    RefreshTokenRequest request,
  ) {
    return _client.post(
      '/auth/refresh',
      body: request.toJson(),
      parser: (json) =>
          RefreshTokenResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<CurrentUserResponse>> getCurrentUser() {
    return _client.get(
      '/auth/me',
      parser: (json) =>
          CurrentUserResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> logout() {
    return _client.post('/auth/logout', parser: (json) => null);
  }

  Future<ApiResponse<void>> changePassword(ChangePasswordRequest request) {
    return _client.post(
      '/auth/change-password',
      body: request.toJson(),
      parser: (json) => null,
    );
  }

  Future<ApiResponse<void>> requestPasswordReset(String email) {
    return _client.post(
      '/auth/request-password-reset',
      body: {'email': email},
      parser: (json) => null,
    );
  }

  Future<ApiResponse<void>> resetPassword(String token, String newPassword) {
    return _client.post(
      '/auth/reset-password',
      body: {'token': token, 'newPassword': newPassword},
      parser: (json) => null,
    );
  }

  Future<ApiResponse<void>> saveProviderToken(String providerToken, {String? providerRefreshToken}) async {
    final response = await _client.post(
      '/auth/provider-token',
      body: {
        'providerToken': providerToken,
        if (providerRefreshToken != null) 'providerRefreshToken': providerRefreshToken,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['accessToken'];
        if (accessToken != null) {
           print('====================================');
           print('BEARER TOKEN FOR POSTMAN:');
           print(accessToken);
           print('====================================');
           
           final prefs = await SharedPreferences.getInstance();
           await prefs.setString('custom_access_token', accessToken);
           _client.authToken = accessToken;
        }
    }
    return ApiResponse(statusCode: response.statusCode, data: null);
  }
}
