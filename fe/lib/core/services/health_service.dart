import 'package:hackathon/core/models/api_response.dart';
import 'package:hackathon/core/models/health_models.dart';
import 'package:hackathon/core/services/api_client.dart';

class HealthService {
  final ApiClient _client;

  HealthService(this._client);

  Future<ApiResponse<HealthResponse>> ping() {
    return _client.get('/', parser: (json) => HealthResponse.fromRaw(json));
  }
}
