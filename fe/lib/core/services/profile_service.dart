import 'package:hackathon/core/models/api_response.dart';
import 'package:hackathon/core/models/profile_models.dart';
import 'package:hackathon/core/services/api_client.dart';

class ProfileService {
  final ApiClient _client;

  ProfileService(this._client);

  Map<String, String>? _authHeaders(String? token) {
    if (token == null || token.isEmpty) return null;
    return {'Authorization': 'Bearer $token'};
  }

  Future<ApiResponse<ClientProfileResponse>> upsertClientProfile(
    ClientProfileDto dto, {
    String? authToken,
  }) {
    return _client.post(
      '/profile/client',
      body: dto.toJson(),
      headers: _authHeaders(authToken),
      parser: (json) =>
          ClientProfileResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ClientProfileResponse>> getClientProfile(
    String userId, {
    String? authToken,
  }) {
    return _client.get(
      '/profile/client/$userId',
      headers: _authHeaders(authToken),
      parser: (json) =>
          ClientProfileResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PsychologistProfileResponse>> upsertPsychologistProfile(
    PsychologistProfileDto dto, {
    String? authToken,
  }) {
    return _client.post(
      '/profile/psychologist',
      body: dto.toJson(),
      headers: _authHeaders(authToken),
      parser: (json) =>
          PsychologistProfileResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PsychologistProfileResponse>> getPsychologistProfile(
    String userId, {
    String? authToken,
  }) {
    return _client.get(
      '/profile/psychologist/$userId',
      headers: _authHeaders(authToken),
      parser: (json) =>
          PsychologistProfileResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<VerificationDocument>>> submitPsychologistDocuments(
    PsychologistDocumentsDto dto, {
    String? authToken,
  }) {
    return _client.post(
      '/profile/psychologist/documents',
      body: dto.toJson(),
      headers: _authHeaders(authToken),
      parser: (json) {
        if (json is List) {
          return json
              .map(
                (e) => VerificationDocument.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<List<VerificationDocument>>> getVerificationDocuments(
    String psychologistId,
  ) {
    return _client.get(
      '/profile/psychologist/$psychologistId/documents',
      parser: (json) {
        if (json is List) {
          return json
              .map(
                (e) => VerificationDocument.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<VerificationDocument>> getVerificationDocument(
    String psychologistId,
    String type,
  ) {
    return _client.get(
      '/profile/psychologist/$psychologistId/documents/$type',
      parser: (json) =>
          VerificationDocument.fromJson(json as Map<String, dynamic>),
    );
  }
}
