import 'package:hackathon/core/models/api_response.dart';
import 'package:hackathon/core/models/human_partner_models.dart';
import 'package:hackathon/core/services/api_client.dart';

class HumanPartnerService {
  final ApiClient _client;

  HumanPartnerService(this._client);

  Future<ApiResponse<HumanPartnerQueueResponse>> joinQueue(
    HumanPartnerQueueRequest request,
  ) {
    return _client.post(
      '/partner/queue/join',
      body: request.toJson(),
      parser: (json) => HumanPartnerQueueResponse.fromJson(json),
    );
  }

  Future<ApiResponse<HumanPartnerQueueResponse>> leaveQueue(
    HumanPartnerQueueRequest request,
  ) {
    return _client.post(
      '/partner/queue/leave',
      body: request.toJson(),
      parser: (json) => HumanPartnerQueueResponse.fromJson(json),
    );
  }

  Future<ApiResponse<HumanPartnerMatchResponse>> getMatch(String id) {
    return _client.get(
      '/partner/match/$id',
      parser: (json) => HumanPartnerMatchResponse.fromJson(json),
    );
  }

  Future<ApiResponse<HumanPartnerMatchResponse>> favoriteMatch(
    String id,
    HumanPartnerFavoriteRequest request,
  ) {
    return _client.post(
      '/partner/match/$id/favorite',
      body: request.toJson(),
      parser: (json) => HumanPartnerMatchResponse.fromJson(json),
    );
  }

  Future<ApiResponse<HumanPartnerMatchResponse>> blockMatch(
    String id,
    HumanPartnerBlockRequest request,
  ) {
    return _client.post(
      '/partner/match/$id/block',
      body: request.toJson(),
      parser: (json) => HumanPartnerMatchResponse.fromJson(json),
    );
  }

  Future<ApiResponse<HumanPartnerMatchResponse>> reportMatch(
    String id,
    HumanPartnerReportRequest request,
  ) {
    return _client.post(
      '/partner/match/$id/report',
      body: request.toJson(),
      parser: (json) => HumanPartnerMatchResponse.fromJson(json),
    );
  }

  Future<ApiResponse<HumanPartnerFavoritesResponse>> getFavorites(
    String userId,
  ) {
    return _client.get(
      '/partner/favorites/$userId',
      parser: (json) => HumanPartnerFavoritesResponse.fromJson(json),
    );
  }
}
