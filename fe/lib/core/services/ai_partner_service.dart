import 'package:hackathon/core/models/ai_partner_models.dart';
import 'package:hackathon/core/models/api_response.dart';
import 'package:hackathon/core/services/api_client.dart';

class AiPartnerService {
  final ApiClient _client;

  AiPartnerService(this._client);

  Future<ApiResponse<AiChatSessionResponse>> createSession(
    AiChatSessionRequest request,
  ) {
    return _client.post(
      '/ai/chat/session',
      body: request.toJson(),
      parser: (json) => AiChatSessionResponse.fromJson(json),
    );
  }

  Future<ApiResponse<AiChatSessionResponse>> getSession(String id) {
    return _client.get(
      '/ai/chat/session/$id',
      parser: (json) => AiChatSessionResponse.fromJson(json),
    );
  }

  Future<ApiResponse<AiChatMessageResponse>> sendMessage(
    String id,
    AiChatMessageRequest request,
  ) {
    return _client.post(
      '/ai/chat/session/$id/message',
      body: request.toJson(),
      parser: (json) => AiChatMessageResponse.fromJson(json),
    );
  }
}
