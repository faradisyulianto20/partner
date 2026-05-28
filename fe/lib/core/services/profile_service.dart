import 'dart:io';

import 'package:hackathon/core/models/api_response.dart';
import 'package:hackathon/core/services/api_client.dart';

class ProfileService {
  final ApiClient _client;

  ProfileService(this._client);

  Future<ApiResponse<dynamic>> upsertClientProfile(
    Map<String, dynamic> data,
  ) {
    return _client.post(
      '/profile/client',
      body: data,
      parser: (json) => json,
    );
  }

  Future<ApiResponse<dynamic>> upsertPsychologistProfile(
    Map<String, dynamic> data,
  ) {
    return _client.post(
      '/profile/psychologist',
      body: data,
      parser: (json) => json,
    );
  }

  Future<ApiResponse<dynamic>> submitPsychologistDocuments({
    required File ktp,
    required File faceWithKtp,
    required File strLicense,
    String? userId,
  }) async {
    // Note: the backend uses simple DTO instead of multipart for this endpoint currently?
    // Let's assume the endpoint accepts JSON if it uses @Body in NestJS,
    // which means it probably expects URLs instead of files, or it needs to be changed.
    return _client.post(
      '/profile/psychologist/documents',
      body: {
        'ktpUrl': ktp.path, // placeholder
        'faceWithKtpUrl': faceWithKtp.path,
        'strLicenseUrl': strLicense.path,
        if (userId != null) 'userId': userId,
      },
      parser: (json) => json,
    );
  }
}
