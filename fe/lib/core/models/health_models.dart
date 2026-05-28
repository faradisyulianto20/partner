class HealthResponse {
  final String message;

  const HealthResponse({required this.message});

  factory HealthResponse.fromRaw(Object? raw) {
    return HealthResponse(message: raw?.toString() ?? '');
  }
}
