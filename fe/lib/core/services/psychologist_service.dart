import 'package:hackathon/core/models/api_response.dart';
import 'package:hackathon/core/models/psychologist_models.dart';
import 'package:hackathon/core/services/api_client.dart';

class PsychologistService {
  final ApiClient _client;

  PsychologistService(this._client);

  Future<ApiResponse<PsychologistSearchResponse>> search(
    PsychologistSearchRequest request,
  ) {
    return _client.post(
      '/psychologist/search',
      body: request.toJson(),
      parser: (json) => PsychologistSearchResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PsychologistDetailResponse>> getDetail(String id) {
    return _client.get(
      '/psychologist/$id',
      parser: (json) => PsychologistDetailResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PsychologistBookingResponse>> createBooking(
    PsychologistBookingRequest request,
  ) {
    return _client.post(
      '/psychologist/booking',
      body: request.toJson(),
      parser: (json) => PsychologistBookingResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PsychologistPayResponse>> payBooking(
    String id,
    PsychologistPayRequest request,
  ) {
    return _client.post(
      '/psychologist/booking/$id/pay',
      body: request.toJson(),
      parser: (json) => PsychologistPayResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PsychologistReviewResponse>> addReview(
    PsychologistReviewRequest request,
  ) {
    return _client.post(
      '/psychologist/review',
      body: request.toJson(),
      parser: (json) => PsychologistReviewResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PsychologistVerificationResponse>> requestVerification(
    PsychologistVerificationRequest request,
  ) {
    return _client.post(
      '/psychologist/verification/request',
      body: request.toJson(),
      parser: (json) => PsychologistVerificationResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PsychologistVerificationResponse>> confirmVerification(
    String token,
  ) {
    return _client.get(
      '/psychologist/verification/confirm/$token',
      parser: (json) => PsychologistVerificationResponse.fromJson(json),
    );
  }
}
